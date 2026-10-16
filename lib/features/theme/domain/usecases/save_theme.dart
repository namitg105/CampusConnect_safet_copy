import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/theme_repository.dart';

class SaveTheme implements UseCase<void, bool> {
  final ThemeRepository themeRepository;
  const SaveTheme(this.themeRepository);

  @override
  Future<Either<Failure, void>> call(bool isLightMode) =>
      themeRepository.saveIsLightMode(isLightMode);
}
