import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

abstract interface class ThemeRepository {
  /// `true` = light mode. Defaults to light when nothing is saved yet.
  Either<Failure, bool> getIsLightMode();

  Future<Either<Failure, void>> saveIsLightMode(bool isLightMode);
}
