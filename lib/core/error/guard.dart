import 'dart:async';

import 'package:fpdart/fpdart.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Runs a data-source call and converts any thrown exception into a
/// [ServerFailure]. Every repository implementation uses this so the
/// try/catch → Left/Right conversion is written once (DRY).
Future<Either<Failure, T>> guardFuture<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

/// Stream version of [guardFuture]: each data event becomes `Right(data)`,
/// each error event becomes `Left(ServerFailure)`.
Stream<Either<Failure, T>> guardStream<T>(Stream<T> source) {
  return source.transform(
    StreamTransformer<T, Either<Failure, T>>.fromHandlers(
      handleData: (data, sink) => sink.add(Right(data)),
      handleError: (error, _, sink) => sink.add(
        Left(ServerFailure(
          error is ServerException ? error.message : error.toString(),
        )),
      ),
    ),
  );
}
