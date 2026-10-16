import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:noteswap/core/error/failures.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/domain/repositories/auth_repository.dart';
import 'package:noteswap/features/auth/domain/usecases/get_current_user.dart';
import 'package:noteswap/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:noteswap/features/auth/domain/usecases/user_login.dart';
import 'package:noteswap/features/auth/domain/usecases/user_login_with_google.dart';
import 'package:noteswap/features/auth/domain/usecases/user_logout.dart';
import 'package:noteswap/features/auth/domain/usecases/user_sign_up.dart';
import 'package:noteswap/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:noteswap/features/auth/presentation/bloc/password_reset_bloc.dart';

const _user = AppUser(
  uid: 'u1',
  email: 'namit@nith.ac.in',
  name: 'Namit',
  collegeId: 'nith.ac.in',
);

/// In-memory stand-in for the Firebase-backed repository.
class FakeAuthRepository implements AuthRepository {
  Either<Failure, AppUser> loginResult = const Right(_user);
  Either<Failure, AppUser?> currentUserResult = const Right(null);
  Either<Failure, AppUser?> googleResult = const Right(_user);
  Either<Failure, void> resetResult = const Right(null);
  bool loggedOut = false;

  @override
  Future<Either<Failure, AppUser>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async =>
      loginResult;

  @override
  Future<Either<Failure, AppUser>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async =>
      loginResult;

  @override
  Future<Either<Failure, AppUser?>> loginWithGoogle() async => googleResult;

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async =>
      currentUserResult;

  @override
  Future<Either<Failure, void>> logout() async {
    loggedOut = true;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async =>
      resetResult;
}

void main() {
  late FakeAuthRepository repo;
  late AuthBloc bloc;

  setUp(() {
    repo = FakeAuthRepository();
    bloc = AuthBloc(
      getCurrentUser: GetCurrentUser(repo),
      userLogin: UserLogin(repo),
      userSignUp: UserSignUp(repo),
      userLoginWithGoogle: UserLoginWithGoogle(repo),
      userLogout: UserLogout(repo),
    );
  });

  tearDown(() => bloc.close());

  test('initial state is AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });

  test('check with no session -> Unauthenticated', () async {
    bloc.add(const AuthCheckRequested());
    await expectLater(bloc.stream, emits(const Unauthenticated()));
  });

  test('check with saved session -> Authenticated', () async {
    repo.currentUserResult = const Right(_user);
    bloc.add(const AuthCheckRequested());
    await expectLater(bloc.stream, emits(const Authenticated(_user)));
  });

  test('login success -> Loading, Authenticated', () async {
    bloc.add(const AuthLoginRequested(email: 'a@b.c', password: 'pw'));
    await expectLater(
      bloc.stream,
      emitsInOrder([const AuthLoading(), const Authenticated(_user)]),
    );
  });

  test('login failure -> Loading, AuthError, Unauthenticated', () async {
    repo.loginResult = const Left(ServerFailure('Login failed: bad password'));
    bloc.add(const AuthLoginRequested(email: 'a@b.c', password: 'pw'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const AuthLoading(),
        const AuthError('Login failed: bad password'),
        const Unauthenticated(),
      ]),
    );
  });

  test('sign up success -> Loading, Authenticated', () async {
    bloc.add(const AuthSignUpRequested(name: 'N', email: 'a@b.c', password: 'pw'));
    await expectLater(
      bloc.stream,
      emitsInOrder([const AuthLoading(), const Authenticated(_user)]),
    );
  });

  test('google picker cancelled -> Loading, Unauthenticated', () async {
    repo.googleResult = const Right(null);
    bloc.add(const AuthGoogleLoginRequested());
    await expectLater(
      bloc.stream,
      emitsInOrder([const AuthLoading(), const Unauthenticated()]),
    );
  });

  test('logout calls repository and emits Unauthenticated', () async {
    repo.currentUserResult = const Right(_user);
    bloc.add(const AuthCheckRequested());
    await expectLater(bloc.stream, emits(const Authenticated(_user)));

    bloc.add(const AuthLogoutRequested());
    await expectLater(bloc.stream, emits(const Unauthenticated()));
    expect(repo.loggedOut, isTrue);
  });

  test('name update only changes the name of the logged-in user', () async {
    repo.currentUserResult = const Right(_user);
    bloc.add(const AuthCheckRequested());
    await expectLater(bloc.stream, emits(const Authenticated(_user)));

    bloc.add(const AuthUserNameUpdated('New Name'));
    await expectLater(
      bloc.stream,
      emits(Authenticated(_user.copyWith(name: 'New Name'))),
    );
  });

  group('PasswordResetBloc', () {
    test('success -> Loading, Sent', () async {
      final resetBloc = PasswordResetBloc(
        sendPasswordResetEmail: SendPasswordResetEmail(repo),
      );
      resetBloc.add(const PasswordResetRequested('a@b.c'));
      await expectLater(
        resetBloc.stream,
        emitsInOrder([const PasswordResetLoading(), const PasswordResetSent()]),
      );
      await resetBloc.close();
    });

    test('failure -> Loading, Failure(message)', () async {
      repo.resetResult = const Left(ServerFailure('no such user'));
      final resetBloc = PasswordResetBloc(
        sendPasswordResetEmail: SendPasswordResetEmail(repo),
      );
      resetBloc.add(const PasswordResetRequested('a@b.c'));
      await expectLater(
        resetBloc.stream,
        emitsInOrder([
          const PasswordResetLoading(),
          const PasswordResetFailure('no such user'),
        ]),
      );
      await resetBloc.close();
    });
  });
}
