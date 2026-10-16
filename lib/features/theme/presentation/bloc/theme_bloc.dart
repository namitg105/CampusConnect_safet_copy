import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_saved_theme.dart';
import '../../domain/usecases/save_theme.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Owns light/dark mode for the whole app. Widgets do NOT listen to this
/// bloc directly: `MaterialApp.themeMode` does, and widgets read
/// `context.isLightMode` (from `Theme.of(context)`), which rebuilds them.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SaveTheme _saveTheme;

  ThemeBloc({
    required GetSavedTheme getSavedTheme,
    required SaveTheme saveTheme,
  })  : _saveTheme = saveTheme,
        super(ThemeState(
          isLightMode: getSavedTheme().getOrElse((_) => true),
        )) {
    on<ThemeToggled>(_onToggled);
  }

  Future<void> _onToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final isLightMode = !state.isLightMode;
    emit(ThemeState(isLightMode: isLightMode));
    // Saving is best-effort: the switch already happened on screen.
    await _saveTheme(isLightMode);
  }
}
