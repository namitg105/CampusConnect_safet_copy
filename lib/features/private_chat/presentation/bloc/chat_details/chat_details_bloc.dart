import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_room.dart';
import '../../../domain/usecases/private_chat_usecases.dart';

/// Chat details screen: room info, shared photos and shared documents.
class ChatDetailsBloc extends Bloc<ChatDetailsStarted, ChatDetailsState> {
  final GetRoomDetails _getDetails;
  final GetSharedImages _getImages;
  final GetSharedDocuments _getDocuments;

  ChatDetailsBloc({
    required GetRoomDetails getRoomDetails,
    required GetSharedImages getSharedImages,
    required GetSharedDocuments getSharedDocuments,
  })  : _getDetails = getRoomDetails,
        _getImages = getSharedImages,
        _getDocuments = getSharedDocuments,
        super(const ChatDetailsState()) {
    on<ChatDetailsStarted>(_onStarted);
  }

  /// The three loads run in parallel; each part appears when it is ready.
  /// On failure a part shows empty, as before.
  Future<void> _onStarted(
    ChatDetailsStarted event,
    Emitter<ChatDetailsState> emit,
  ) async {
    await Future.wait([
      _getDetails(RoomUserParams(roomId: event.roomId, uid: event.currentUid))
          .then((r) => r.fold(
                (f) => debugPrint('Room details: ${f.message}'),
                (details) => emit(state.copyWith(details: details)),
              )),
      _getImages(event.roomId).then((r) => emit(state.copyWith(
            images: r.getOrElse((_) => const []),
            imagesLoaded: true,
          ))),
      _getDocuments(event.roomId).then((r) => emit(state.copyWith(
            documents: r.getOrElse((_) => const []),
            documentsLoaded: true,
          ))),
    ]);
  }
}

final class ChatDetailsStarted extends Equatable {
  final String roomId;
  final String currentUid;
  const ChatDetailsStarted({required this.roomId, required this.currentUid});

  @override
  List<Object?> get props => [roomId, currentUid];
}

final class ChatDetailsState extends Equatable {
  final RoomDetails? details;
  final List<String> images;
  final bool imagesLoaded;
  final List<SharedFile> documents;
  final bool documentsLoaded;

  const ChatDetailsState({
    this.details,
    this.images = const [],
    this.imagesLoaded = false,
    this.documents = const [],
    this.documentsLoaded = false,
  });

  ChatDetailsState copyWith({
    RoomDetails? details,
    List<String>? images,
    bool? imagesLoaded,
    List<SharedFile>? documents,
    bool? documentsLoaded,
  }) {
    return ChatDetailsState(
      details: details ?? this.details,
      images: images ?? this.images,
      imagesLoaded: imagesLoaded ?? this.imagesLoaded,
      documents: documents ?? this.documents,
      documentsLoaded: documentsLoaded ?? this.documentsLoaded,
    );
  }

  @override
  List<Object?> get props =>
      [details, images, imagesLoaded, documents, documentsLoaded];
}
