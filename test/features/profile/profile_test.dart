import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';
import 'package:noteswap/features/posts/domain/repos/post_repo.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:noteswap/features/profile/domain/entities/user_profile.dart';
import 'package:noteswap/features/profile/domain/repos/profile_repo.dart';
import 'package:noteswap/features/profile/domain/usecases/profile_usecases.dart';
import 'package:noteswap/features/profile/presentation/bloc/profile_bloc.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

class FakeProfileRepo implements ProfileRepo {
  UserProfile? profile =
      const UserProfile(uid: 'me', name: 'Old', bio: 'b', profileImage: 'url');
  Failure? saveFailure;
  ProfileImageChange? lastImage;
  String? lastCurrentImage;
  int reads = 0;

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String uid) async {
    reads++;
    return Right(profile);
  }

  @override
  Future<Either<Failure, String>> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required ProfileImageChange image,
    required String? currentImageUrl,
  }) async {
    lastImage = image;
    lastCurrentImage = currentImageUrl;
    if (saveFailure != null) return Left(saveFailure!);
    profile = UserProfile(uid: uid, name: name, bio: bio);
    return Right(name);
  }
}

class FakePostRepo implements PostRepo {
  String? askedCollege;
  List<PostEntity> feed = [];

  @override
  Future<Either<Failure, List<PostEntity>>> getCollegeFeed(String c) async {
    askedCollege = c;
    return Right(feed);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PostEntity _post(String id, String tag) => PostEntity(
      id: id,
      title: id,
      body: '',
      authorId: 'a',
      authorName: 'A',
      collegeId: 'c',
      upvotes: 0,
      commentCount: 0,
      tag: tag,
      createdAt: DateTime(2026),
    );

void main() {
  late FakeProfileRepo repo;
  setUp(() => repo = FakeProfileRepo());

  ProfileBloc bloc() =>
      ProfileBloc(getProfile: GetProfile(repo), updateProfile: UpdateProfile(repo));

  test('legacy document keys are all read', () {
    final p = ProfileRemoteDataSourceImpl.fromMap('u', {
      'displayName': 'Disp',
      'imageUrl': 'img',
      'collegeId': 'nith.ac.in',
    });
    expect(p.name, 'Disp');
    expect(p.profileImage, 'img');
    expect(p.hasImage, isTrue);
    expect(p.collegeId, 'nith.ac.in');
  });

  test('load then save reloads the profile and reports the name', () async {
    final b = bloc()..add(const ProfileRequested('me'));
    await _settle();
    expect(b.state.loaded, isTrue);
    expect(b.state.profile!.name, 'Old');

    b.add(const ProfileUpdateRequested(
        uid: 'me', name: 'New', bio: 'hi', image: ResetImage()));
    await _settle();
    expect(b.state.saving, isFalse);
    expect(b.state.savedName, 'New');
    expect(b.state.saveError, isNull);
    expect(b.state.saveId, 1);
    expect(b.state.profile!.name, 'New');
    expect(repo.lastImage, isA<ResetImage>());
    expect(repo.lastCurrentImage, 'url');
    await b.close();
  });

  test('failed save keeps the profile and reports an error', () async {
    repo.saveFailure = const ServerFailure('storage/unauthorized');
    final b = bloc()..add(const ProfileRequested('me'));
    await _settle();
    b.add(const ProfileUpdateRequested(uid: 'me', name: 'X', bio: ''));
    await _settle();
    expect(b.state.saveError, 'Failed to update profile: storage/unauthorized');
    expect(b.state.profile!.name, 'Old');
    expect(b.state.saveId, 1);
    await b.close();
  });

  group('DashboardBloc', () {
    late FakePostRepo posts;
    setUp(() => posts = FakePostRepo());

    DashboardBloc dash() => DashboardBloc(
        getProfile: GetProfile(repo), getFeed: GetFeedUseCase(repository: posts));

    const user = AppUser(uid: 'me', email: 'me@x.in', name: 'Me', collegeId: 'auth-college');

    test('uses the profile collegeId, else the auth one', () async {
      repo.profile = const UserProfile(uid: 'me', collegeId: 'profile-college');
      final b = dash()..add(const DashboardLoadRequested(user));
      await _settle();
      expect(posts.askedCollege, 'profile-college');

      repo.profile = null;
      b.add(const DashboardLoadRequested(user, refresh: true));
      await _settle();
      expect(posts.askedCollege, 'auth-college');
      await b.close();
    });

    test('newest 3 + announcements; same user is not reloaded', () async {
      posts.feed = [
        _post('1', 'Announcement'),
        _post('2', 'General'),
        _post('3', 'General'),
        _post('4', 'announcement'),
      ];
      final b = dash()..add(const DashboardLoadRequested(user));
      await _settle();
      expect(b.state.newestDiscussions.map((p) => p.id), ['1', '2', '3']);
      expect(b.state.announcements.map((p) => p.id), ['1', '4']);
      expect(b.state.loading, isFalse);

      final readsBefore = repo.reads;
      b.add(const DashboardLoadRequested(user));
      await _settle();
      expect(repo.reads, readsBefore);
      await b.close();
    });
  });
}

