import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  /// `true` when the app is in light mode.
  ///
  /// Reads `Theme.of(context)`, so the calling widget rebuilds automatically
  /// whenever `ThemeBloc` flips `MaterialApp.themeMode`.
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;
}
