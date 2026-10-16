part of 'theme_bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Flip between light and dark mode.
final class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}
