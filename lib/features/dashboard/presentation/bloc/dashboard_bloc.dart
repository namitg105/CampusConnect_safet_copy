import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../posts/domain/entities/post_entity.dart';
import '../../../posts/domain/usecases/get_feed_usecase.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/usecases/profile_usecases.dart';

/// Home dashboard: greeting name, newest discussions and announcements.
/// Composes the profile and posts use cases (no data layer of its own).
class DashboardBloc extends Bloc<DashboardLoadRequested, DashboardState> {
  final GetProfile _getProfile;
  final GetFeedUseCase _getFeed;

  DashboardBloc({
    required GetProfile getProfile,
    required GetFeedUseCase getFeed,
  })  : _getProfile = getProfile,
        _getFeed = getFeed,
        super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final user = event.user;
    // Same user already shown: only a pull-to-refresh reloads.
    if (state.loadedUid == user.uid && !state.loading && !event.refresh) {
      return;
    }
    emit(state.copyWith(loading: true, refreshing: event.refresh));

    final profile = (await _getProfile(user.uid)).getOrElse((_) => null);
    final collegeId = profile?.collegeId ?? user.collegeId;

    var feed = const <PostEntity>[];
    if (collegeId.isNotEmpty) {
      final result = await _getFeed(collegeId);
      result.fold(
        (f) => debugPrint('[Dashboard] Error fetching feed: ${f.message}'),
        (posts) => feed = posts,
      );
    }

    emit(DashboardState(
      loadedUid: user.uid,
      profile: profile,
      newestDiscussions: feed.take(3).toList(),
      announcements:
          feed.where((p) => p.tag.toLowerCase() == 'announcement').toList(),
    ));
  }
}

final class DashboardLoadRequested extends Equatable {
  final AppUser user;

  /// Pull-to-refresh: reload even if this user is already shown.
  final bool refresh;
  const DashboardLoadRequested(this.user, {this.refresh = false});

  @override
  List<Object?> get props => [user, refresh];
}

final class DashboardState extends Equatable {
  final String? loadedUid;
  final UserProfile? profile;
  final List<PostEntity> newestDiscussions;
  final List<PostEntity> announcements;
  final bool loading;
  final bool refreshing;

  const DashboardState({
    this.loadedUid,
    this.profile,
    this.newestDiscussions = const [],
    this.announcements = const [],
    this.loading = false,
    this.refreshing = false,
  });

  DashboardState copyWith({bool? loading, bool? refreshing}) {
    return DashboardState(
      loadedUid: loadedUid,
      profile: profile,
      newestDiscussions: newestDiscussions,
      announcements: announcements,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
    );
  }

  @override
  List<Object?> get props => [
        loadedUid,
        profile,
        newestDiscussions,
        announcements,
        loading,
        refreshing,
      ];
}
