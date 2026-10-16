part of 'theme_bloc.dart';

final class ThemeState extends Equatable {
  final bool isLightMode;
  const ThemeState({required this.isLightMode});

  @override
  List<Object?> get props => [isLightMode];
}
