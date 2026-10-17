import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note_entities.dart';
import '../../domain/usecases/notes_usecases.dart';

/// One open note: its details, buying it, and counting downloads.
class NoteDetailBloc extends Bloc<NoteDetailEvent, NoteDetailState> {
  final GetNoteDetail _getDetail;
  final PurchaseNote _purchase;
  final RecordDownload _recordDownload;

  NoteDetailBloc({
    required GetNoteDetail getNoteDetail,
    required PurchaseNote purchaseNote,
    required RecordDownload recordDownload,
  })  : _getDetail = getNoteDetail,
        _purchase = purchaseNote,
        _recordDownload = recordDownload,
        super(const NoteDetailState()) {
    on<NoteDetailRequested>((event, emit) => _load(event.note, emit));
    on<NotePurchaseRequested>(_onPurchase);
    on<NoteDownloadRecorded>((event, emit) async {
      final detail = state.detail;
      if (detail != null) {
        await _recordDownload(NoteUserParams(detail, event.uid));
      }
    });
  }

  /// Shown when the note cannot be loaded (same as before the refactor).
  static const unavailable = NoteDetail(
    title: 'Note unavailable',
    subject: '',
    author: '',
    price: 'Free',
    rating: 0,
    ratingCount: 0,
    images: [],
    semester: '—',
    pages: '—',
    language: 'English',
    fileSize: '',
    downloads: 0,
    sellerName: '',
    sellerJoined: '',
    sellerNotes: 0,
    sellerAccent: Color(0xFF6366F1),
    reviews: [],
  );

  Future<void> _load(Note note, Emitter<NoteDetailState> emit) async {
    final result = await _getDetail(note);
    emit(state.copyWith(detail: result.getOrElse((_) => unavailable)));
  }

  Future<void> _onPurchase(
    NotePurchaseRequested event,
    Emitter<NoteDetailState> emit,
  ) async {
    if (event.uid.isEmpty) {
      emit(state.withMessage('Please sign in to buy notes', isError: true));
      return;
    }
    emit(state.copyWith(purchasing: true));
    final result = await _purchase(NoteUserParams(event.note, event.uid));
    await result.fold(
      (failure) async => emit(state
          .copyWith(purchasing: false)
          .withMessage('Could not purchase note: ${failure.message}',
              isError: true)),
      (_) async {
        // Reload so the detail reflects isPurchased (buyers list changed).
        await _load(event.note, emit);
        emit(state
            .copyWith(purchasing: false)
            .withMessage('Note purchased successfully'));
      },
    );
  }
}

sealed class NoteDetailEvent extends Equatable {
  const NoteDetailEvent();

  @override
  List<Object?> get props => [];
}

final class NoteDetailRequested extends NoteDetailEvent {
  final Note note;
  const NoteDetailRequested(this.note);
}

final class NotePurchaseRequested extends NoteDetailEvent {
  final Note note;
  final String uid;
  const NotePurchaseRequested(this.note, this.uid);

  @override
  List<Object?> get props => [uid];
}

/// The file is being opened: count the download (best-effort).
final class NoteDownloadRecorded extends NoteDetailEvent {
  final String uid;
  const NoteDownloadRecorded(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class NoteDetailState extends Equatable {
  /// Null while loading.
  final NoteDetail? detail;
  final bool purchasing;

  /// Snackbar text; [messageId] makes repeats distinct.
  final String message;
  final bool messageIsError;
  final int messageId;

  const NoteDetailState({
    this.detail,
    this.purchasing = false,
    this.message = '',
    this.messageIsError = false,
    this.messageId = 0,
  });

  NoteDetailState copyWith({NoteDetail? detail, bool? purchasing}) {
    return NoteDetailState(
      detail: detail ?? this.detail,
      purchasing: purchasing ?? this.purchasing,
      message: message,
      messageIsError: messageIsError,
      messageId: messageId,
    );
  }

  NoteDetailState withMessage(String text, {bool isError = false}) {
    return NoteDetailState(
      detail: detail,
      purchasing: purchasing,
      message: text,
      messageIsError: isError,
      messageId: messageId + 1,
    );
  }

  @override
  List<Object?> get props =>
      [detail, purchasing, message, messageIsError, messageId];
}
