import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';

/// One profile shown on a screen (own profile, dashboard greeting, or a
/// post author's page), and saving your own profile.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUpdateRequested>(_onUpdate);
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    final result = await _getProfile(event.uid);
    result.fold(
      // Before: a failed read just showed the fallback (auth) data.
      (_) => emit(state.copyWith(loading: false, loaded: true)),
      (profile) => emit(ProfileState(profile: profile, loaded: true)),
    );
  }

  Future<void> _onUpdate(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(saving: true));
    final result = await _updateProfile(UpdateProfileParams(
      uid: event.uid,
      name: event.name,
      bio: event.bio,
      image: event.image,
      currentImageUrl: state.profile?.profileImage,
    ));
    await result.fold(
      (failure) async => emit(state
          .copyWith(saving: false)
          .withSaveResult(error: 'Failed to update profile: ${failure.message}')),
      (savedName) async {
        final reloaded = await _getProfile(event.uid);
        emit(ProfileState(
          profile: reloaded.getOrElse((_) => state.profile),
          loaded: true,
        ).withSaveResult(savedName: savedName, previous: state));
      },
    );
  }
}

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileRequested extends ProfileEvent {
  final String uid;
  const ProfileRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class ProfileUpdateRequested extends ProfileEvent {
  final String uid;
  final String name;
  final String bio;
  final ProfileImageChange image;

  const ProfileUpdateRequested({
    required this.uid,
    required this.name,
    required this.bio,
    this.image = const KeepImage(),
  });

  @override
  List<Object?> get props => [uid, name, bio, image];
}

final class ProfileState extends Equatable {
  final UserProfile? profile;
  final bool loading;

  /// True once the first load finished (successfully or not).
  final bool loaded;
  final bool saving;

  /// Result of the last save; [saveId] makes repeated saves distinct.
  final String? savedName;
  final String? saveError;
  final int saveId;

  const ProfileState({
    this.profile,
    this.loading = false,
    this.loaded = false,
    this.saving = false,
    this.savedName,
    this.saveError,
    this.saveId = 0,
  });

  ProfileState copyWith({bool? loading, bool? loaded, bool? saving}) {
    return ProfileState(
      profile: profile,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      saving: saving ?? this.saving,
      savedName: savedName,
      saveError: saveError,
      saveId: saveId,
    );
  }

  ProfileState withSaveResult({
    String? savedName,
    String? error,
    ProfileState? previous,
  }) {
    return ProfileState(
      profile: profile,
      loading: loading,
      loaded: loaded,
      saving: false,
      savedName: savedName,
      saveError: error,
      saveId: (previous ?? this).saveId + 1,
    );
  }

  @override
  List<Object?> get props =>
      [profile, loading, loaded, saving, savedName, saveError, saveId];
}
