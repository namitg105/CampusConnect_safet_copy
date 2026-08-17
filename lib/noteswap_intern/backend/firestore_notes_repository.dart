import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../features/events/notifications/models/notification_model.dart';
import '../../features/events/notifications/services/notification_service.dart';
import '../my_notes_data.dart';
import '../note_data.dart';
import '../note_details_data.dart';
import 'note_models.dart';
import 'note_storage_service.dart';
import 'notes_repository.dart';

/// Real backend implementation backed by Firestore + Firebase Storage.
///
/// Collections used (all already covered by the project's Firestore rules):
///   * `noteswap_notes/{noteId}`                         the uploaded note
///   * `noteswap_notes/{noteId}/reviews/{userId}`        one review per user
///   * `noteswap_bought_notes/{docId}`                   purchase receipts
///   * `users/{uid}`                                     additive stat fields
class FirestoreNotesRepository implements NotesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NoteStorageService _storage = NoteStorageService();

  CollectionReference<Map<String, dynamic>> get _notes =>
      _db.collection('noteswap_notes');
  CollectionReference<Map<String, dynamic>> get _boughtNotes =>
      _db.collection('noteswap_bought_notes');

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  @override
  Future<List<Note>> getFeaturedNotes() async {
    final snap =
        await _notes.orderBy('createdAt', descending: true).limit(20).get();
    return snap.docs
        .where((d) => _isValidNote(d.data() ?? {}))
        .take(2)
        .map(_toNote)
        .toList();
  }

  @override
  Future<List<Note>> getRecentNotes() async {
    final snap =
        await _notes.orderBy('createdAt', descending: true).limit(20).get();
    return snap.docs
        .where((d) => _isValidNote(d.data() ?? {}))
        .take(3)
        .map(_toNote)
        .toList();
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final snap = await _notes.limit(100).get();
    final notes = snap.docs
        .where((d) => _isValidNote(d.data() ?? {}))
        .map(_toNote)
        .toList();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return notes;
    return notes.where((note) {
      return note.title.toLowerCase().contains(q) ||
          note.subject.toLowerCase().contains(q) ||
          note.author.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<NoteDetail> getNoteDetail(String noteId) async {
    final doc = await _notes.doc(noteId).get();
    if (!doc.exists) return _fallbackDetail(noteId);
    final data = doc.data() ?? {};

    final reviewsSnap = await _notes
        .doc(noteId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    final reviews = reviewsSnap.docs.map((d) {
      final r = d.data();
      final rts = r['createdAt'];
      return Review(
        name: r['userName'] ?? 'User',
        rating: (toNum(r['rating']) ?? 0).toDouble(),
        time: relativeTime(rts is Timestamp ? rts.toDate() : null),
        text: r['text'] ?? '',
      );
    }).toList();

    final ratingSum = (toNum(data['ratingSum']) ?? 0).toDouble();
    final ratingCount = (toNum(data['ratingCount']) ?? 0).toInt();
    final avg = ratingCount == 0 ? 0.0 : ratingSum / ratingCount;
    final price = toNum(data['price']) ?? 0;
    final isFree = (data['isFree'] as bool?) ?? price <= 0;
    final previewImages =
        (data['previewImages'] as List?)?.whereType<String>().toList() ??
            const <String>[];
    final buyers =
        (data['buyers'] as List?)?.whereType<String>().toList() ??
            const <String>[];
    final authorId = data['authorId'] ?? '';
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    int sellerNotes = 0;
    if (authorId is String && authorId.isNotEmpty) {
      try {
        final authorDoc =
            await _db.collection('users').doc(authorId).get();
        sellerNotes =
            (toNum(authorDoc.data()?['notesCount']) ?? 0).toInt();
      } catch (_) {}
    }

    return NoteDetail(
      noteId: noteId,
      title: data['title'] ?? 'Untitled',
      subject: data['subject'] ?? '',
      author: data['authorName'] ?? '',
      price: isFree ? 'Free' : '₹${price.round()}',
      rating: double.parse(avg.toStringAsFixed(1)),
      ratingCount: ratingCount,
      images: previewImages,
      semester: data['semester'] ?? '—',
      pages: '—',
      language: 'English',
      fileSize: formatBytes((toNum(data['fileSize']) ?? 0).toInt()),
      downloads: (toNum(data['downloads']) ?? 0).toInt(),
      sellerName: data['authorName'] ?? '',
      sellerJoined: '',
      sellerNotes: sellerNotes,
      sellerAccent: noteAccentFor(data['subject'] ?? ''),
      reviews: reviews,
      fileUrl: data['fileUrl'] ?? '',
      isOwner: authorId == uid,
      isPurchased: uid.isNotEmpty && buyers.contains(uid),
    );
  }

  @override
  Future<List<DashboardNote>> getMyNotes(String uid) async {
    final snap =
        await _notes.where('authorId', isEqualTo: uid).get();
    return snap.docs
        .where((d) => _isValidNote(d.data() ?? {}))
        .map(_toDashboardNote)
        .toList();
  }

  @override
  Future<List<DashboardNote>> getBoughtNotes(String uid) async {
    final boughtSnap =
        await _boughtNotes.where('buyerId', isEqualTo: uid).get();

    final noteIds =
        boughtSnap.docs.map((b) => b.data()['noteId']).whereType<String>().toList();
    if (noteIds.isEmpty) return const [];

    // Batch-fetch all notes in one call instead of one query per receipt.
    final notesById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    if (noteIds.length <= 10) {
      final noteSnap = await _notes.where(FieldPath.documentId, whereIn: noteIds).get();
      for (final d in noteSnap.docs) {
        notesById[d.id] = d;
      }
    } else {
      for (var i = 0; i < noteIds.length; i += 10) {
        final chunk = noteIds.sublist(i, (i + 10).clamp(0, noteIds.length));
        final noteSnap = await _notes
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final d in noteSnap.docs) {
          notesById[d.id] = d;
        }
      }
    }

    final notes = <DashboardNote>[];
    for (final id in noteIds) {
      final doc = notesById[id];
      if (doc != null && _isValidNote(doc.data() ?? {})) {
        notes.add(_toDashboardNote(doc));
      }
    }
    return notes;
  }

  // ---------------------------------------------------------------------------
  // Writes
  // ---------------------------------------------------------------------------

  @override
  Future<void> uploadNote(NoteUploadData data, {required String uid}) async {
    if (uid.isEmpty) {
      throw Exception('Missing user — sign in to upload notes.');
    }
    if (data.title.trim().isEmpty || data.filePath.trim().isEmpty) {
      throw Exception('Note needs a title and a file.');
    }

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final collegeId =
        email.contains('@') ? email.split('@').last.toLowerCase() : 'unknown';
    final authorName = user?.displayName ??
        (email.contains('@') ? email.split('@').first : 'Unknown');

    // 1) Storage FIRST, then Firestore. A Storage failure (e.g. credits ended)
    //    aborts here before any Firestore document is written.
    final uploaded = await _storage.uploadNote(data: data, uid: uid);

    // 2) Note document + author's notes count in ONE transaction so a failure
    //    can never leave a stray note without its counter (or vice versa).
    final docRef = _notes.doc();
    await _db.runTransaction((txn) async {
      txn.set(docRef, {
        'title': data.title,
        'subject': data.subject,
        'courseCode': data.courseCode,
        'semester': data.semester,
        'description': data.description,
        'price': data.price,
        'isFree': data.isFree,
        'authorId': uid,
        'authorName': authorName,
        'authorImage': user?.photoURL ?? '',
        'collegeId': collegeId,
        'fileUrl': uploaded.fileUrl,
        'fileName': data.fileName,
        'fileSize': data.fileSize,
        'previewImages': uploaded.previewUrls,
        'buyers': const <String>[],
        'downloads': 0,
        'ratingSum': 0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.set(
        _db.collection('users').doc(uid),
        {'notesCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<void> deleteNote(String noteId, {required String uid}) async {
    if (uid.isEmpty) {
      throw Exception('Missing user — sign in to delete notes.');
    }

    final doc = await _notes.doc(noteId).get();
    if (!doc.exists) return;
    final data = doc.data() ?? {};
    final authorId = data['authorId'] ?? '';

    // Ownership guard: only the author may delete.
    if (authorId != uid) {
      throw Exception('You can only delete your own notes.');
    }

    // A note that already has buyers can no longer be deleted.
    final buyers =
        (data['buyers'] as List?)?.whereType<String>().toList() ??
            const <String>[];
    if (buyers.isNotEmpty) {
      throw NoteHasBuyersException();
    }

    final fileUrl = data['fileUrl'] ?? '';
    final previewImages =
        (data['previewImages'] as List?)?.whereType<String>().toList() ??
            const <String>[];

    // Firestore FIRST (doc + reviews + buyer receipts in one batch), then
    // Storage cleanup. If the batch fails nothing is deleted; orphaned Storage
    // files only occur if the batch succeeds and Storage cleanup fails, which
    // is the safer failure mode and is best-effort.
    final reviewsSnap =
        await _notes.doc(noteId).collection('reviews').get();
    final boughtSnap = await _boughtNotes
        .where('noteId', isEqualTo: noteId)
        .get();
    final batch = _db.batch();
    for (final r in reviewsSnap.docs) {
      batch.delete(r.reference);
    }
    for (final b in boughtSnap.docs) {
      batch.delete(b.reference);
    }
    batch.delete(_notes.doc(noteId));
    await batch.commit();

    // Best-effort: counter and Storage. A failure here must NOT fail the delete.
    if (authorId is String && authorId.isNotEmpty) {
      try {
        await _db.collection('users').doc(authorId).set(
              {'notesCount': FieldValue.increment(-1)},
              SetOptions(merge: true),
            );
      } catch (_) {}
    }
    if (fileUrl is String && fileUrl.isNotEmpty) {
      try {
        await _storage.deleteNoteFiles(
          fileUrl: fileUrl,
          previewUrls: previewImages,
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> purchaseNote(String noteId, String buyerUid) async {
    final noteRef = _notes.doc(noteId);
    String? authorId;

    await _db.runTransaction((txn) async {
      final snap = await txn.get(noteRef);
      if (!snap.exists) throw Exception('Note not found');
      final data = snap.data() ?? {};
      final String? author = data['authorId'] as String?;
      authorId = author;

      final buyers =
          (data['buyers'] as List?)?.cast<String>() ?? const <String>[];
      if (buyers.contains(buyerUid)) return; // already purchased -> no-op

      if (author == buyerUid) {
        throw Exception('You cannot buy your own note');
      }

      final price = toNum(data['price']) ?? 0;

      // Order matters: note updated before the receipt so the Firestore rule
      // for `noteswap_bought_notes` (buyer must be in note.buyers) sees the
      // update.
      txn.update(noteRef, {
        'buyers': FieldValue.arrayUnion([buyerUid]),
      });

      final boughtRef = _boughtNotes.doc();
      txn.set(boughtRef, {
        'buyerId': buyerUid,
        'noteId': noteId,
        'authorId': author,
        'noteTitle': data['title'] ?? '',
        'price': price,
        'fileUrl': data['fileUrl'] ?? '',
        'boughtAt': FieldValue.serverTimestamp(),
      });

      if (author != null && author.isNotEmpty) {
        txn.set(
          _db.collection('users').doc(author),
          {
            'notesSold': FieldValue.increment(1),
            'totalEarnings': FieldValue.increment(price),
          },
          SetOptions(merge: true),
        );
      }
    });

    // Notify the seller after the transaction commits.
    final String? sellerId = authorId;
    if (sellerId != null && sellerId.isNotEmpty && sellerId != buyerUid) {
      try {
        await NotificationService.createNotification(
          recipientId: sellerId,
          type: NotificationType.announcement,
          title: 'Your note was purchased',
          subtitle: 'A student bought your note on Noteswap',
          description: 'Check your notes dashboard for details.',
          targetId: noteId,
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> recordDownload(String noteId, String uid) async {
    if (noteId.isEmpty || uid.isEmpty) return;
    final noteRef = _notes.doc(noteId);
    try {
      await _db.runTransaction((txn) async {
        final snap = await txn.get(noteRef);
        if (!snap.exists) return;
        final data = snap.data() ?? {};
        final authorId = data['authorId'] ?? '';
        final buyers =
            (data['buyers'] as List?)?.whereType<String>().toList() ??
                const <String>[];

        // Only the owner or a buyer may bump the counter. Rules enforce this
        // server-side too; this client-side check avoids a wasted write.
        if (authorId == uid || buyers.contains(uid)) {
          txn.update(noteRef, {'downloads': FieldValue.increment(1)});
        }
      });
    } catch (_) {
      // Download counting is best-effort; never block opening the file.
    }
  }

  @override
  Future<void> addReview(ReviewDraft draft) async {
    final noteRef = _notes.doc(draft.noteId);
    final reviewRef =
        noteRef.collection('reviews').doc(draft.userId);

    await _db.runTransaction((txn) async {
      final oldSnap = await txn.get(reviewRef);
      final oldRating = oldSnap.exists
          ? (toNum(oldSnap.data()?['rating']) ?? 0).toDouble()
          : null;

      txn.set(reviewRef, {
        'userId': draft.userId,
        'userName': draft.userName,
        'rating': draft.rating,
        'text': draft.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (oldRating == null) {
        txn.update(noteRef, {
          'ratingSum': FieldValue.increment(draft.rating),
          'ratingCount': FieldValue.increment(1),
        });
      } else {
        txn.update(noteRef, {
          'ratingSum': FieldValue.increment(draft.rating - oldRating),
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  /// A note only counts as "real" when it has both a title and an uploaded
  /// file. Legacy/placeholder documents (missing title or fileUrl) are hidden.
  bool _isValidNote(Map<String, dynamic> data) {
    final title = data['title'];
    final fileUrl = data['fileUrl'];
    return title is String &&
        title.trim().isNotEmpty &&
        fileUrl is String &&
        fileUrl.trim().isNotEmpty;
  }

  Note _toNote(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    return Note(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      subject: data['subject'] ?? '',
      author: data['authorName'] ?? 'Unknown',
      uploadTime: relativeTime(ts is Timestamp ? ts.toDate() : null),
      downloads: (toNum(data['downloads']) ?? 0).toInt(),
      accent: noteAccentFor(data['subject'] ?? ''),
    );
  }

  DashboardNote _toDashboardNote(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['createdAt'];
    final buyers =
        (data['buyers'] as List?)?.cast<String>() ?? const <String>[];
    final ratingSum = (toNum(data['ratingSum']) ?? 0).toDouble();
    final ratingCount = (toNum(data['ratingCount']) ?? 0).toInt();
    final avg = ratingCount == 0 ? 0.0 : ratingSum / ratingCount;

    return DashboardNote(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      subject: data['subject'] ?? '',
      semester: data['semester'] ?? '—',
      uploadTime: relativeTime(ts is Timestamp ? ts.toDate() : null),
      price: (toNum(data['price']) ?? 0).round(),
      accent: noteAccentFor(data['subject'] ?? ''),
      authorId: data['authorId'] ?? '',
      buyerIds: buyers,
      ratings: [avg],
    );
  }

  NoteDetail _fallbackDetail(String noteId) {
    return NoteDetail(
      noteId: noteId,
      title: 'Note',
      subject: '',
      author: '',
      price: 'Free',
      rating: 0,
      ratingCount: 0,
      images: const [],
      semester: '—',
      pages: '—',
      language: 'English',
      fileSize: '',
      downloads: 0,
      sellerName: '',
      sellerJoined: '',
      sellerNotes: 0,
      sellerAccent: const Color(0xFF6366F1),
      reviews: const [],
      fileUrl: '',
      isOwner: false,
      isPurchased: false,
    );
  }
}
