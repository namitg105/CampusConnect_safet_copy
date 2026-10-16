import 'package:equatable/equatable.dart';

/// A [Failure] is what the domain layer hands back when something went wrong.
///
/// Data sources throw exceptions; repositories catch them and convert them
/// into a [Failure] wrapped in `Left(...)`, so the presentation layer never
/// has to deal with raw Firebase exceptions.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Remote (Firebase Auth / Firestore / Storage) operation failed.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

/// Local storage (Hive / GetStorage) operation failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}
