import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;
  const ThemeRepositoryImpl(this.localDataSource);

  @override
  Either<Failure, bool> getIsLightMode() {
    try {
      return Right(localDataSource.readIsLightMode() ?? true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveIsLightMode(bool isLightMode) async {
    try {
      return Right(await localDataSource.writeIsLightMode(isLightMode));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
