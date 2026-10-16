import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Every one-shot use case (login, create post, ...) implements this.
/// It returns either a [Failure] (Left) or the result (Right).
abstract interface class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

/// Every real-time use case (Firestore snapshots: chat messages, groups, ...)
/// implements this. Each event on the stream is either a [Failure] or data.
abstract interface class StreamUseCase<SuccessType, Params> {
  Stream<Either<Failure, SuccessType>> call(Params params);
}

/// Used by use cases that need no input, e.g. `GetCurrentUser`.
class NoParams {
  const NoParams();
}
