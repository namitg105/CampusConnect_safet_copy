import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/theme_repository.dart';

/// Synchronous on purpose: the theme must be known before the first frame.
class GetSavedTheme {
  final ThemeRepository themeRepository;
  const GetSavedTheme(this.themeRepository);

  Either<Failure, bool> call() => themeRepository.getIsLightMode();
}
