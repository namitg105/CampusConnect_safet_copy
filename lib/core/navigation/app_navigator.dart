import 'dart:async';

import 'package:flutter/material.dart';

/// Root keys handed to `MaterialApp` in `main.dart`. They let code that has
/// no `BuildContext` (old controllers, services) still navigate and show
/// snackbars — which is exactly what GetX did internally.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum SnackPosition { top, bottom }

/// Thin wrapper over Flutter's own [Navigator], [showDialog] and
/// [ScaffoldMessenger]. Replaces `Get.to`, `Get.back`, `Get.snackbar`, ...
abstract final class AppNavigator {
  static NavigatorState get _navigator => rootNavigatorKey.currentState!;

  static Route<T> _route<T>(Widget page) =>
      MaterialPageRoute<T>(builder: (_) => page);

  /// Open [page] on top of the current screen. (was `Get.to`)
  static Future<T?> push<T>(Widget page) => _navigator.push<T>(_route(page));

  /// Replace the current screen with [page]. (was `Get.off`)
  static Future<T?> replace<T>(Widget page) =>
      _navigator.pushReplacement<T, Object?>(_route(page));

  /// Clear the whole stack and show [page]. (was `Get.offAll`)
  static Future<T?> replaceAll<T>(Widget page) =>
      _navigator.pushAndRemoveUntil<T>(_route(page), (_) => false);

  /// Close the top route (screen, dialog or bottom sheet). (was `Get.back`)
  static void pop<T>([T? result]) => _navigator.pop<T>(result);

  /// Close the top [count] routes. (was `Get.close(count)`)
  static void popTimes(int count) {
    for (var i = 0; i < count && _navigator.canPop(); i++) {
      _navigator.pop();
    }
  }

  /// Show [dialog] above everything. (was `Get.dialog`)
  static Future<T?> showAppDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: _navigator.context,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }

  /// Title + message snackbar. (was `Get.snackbar`)
  static void showSnackbar(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.top,
    Color? backgroundColor,
    Color? colorText,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
    Widget? titleText,
    Widget? messageText,
    EdgeInsets margin = const EdgeInsets.all(12),
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    double borderRadius = 12,
    bool isDismissible = true,
  }) {
    final content = _SnackContent(
      title: title,
      message: message,
      colorText: colorText ?? Colors.white,
      icon: icon,
      titleText: titleText,
      messageText: messageText,
    );
    final background = backgroundColor ?? const Color(0xFF303030);

    if (snackPosition == SnackPosition.bottom) {
      final messenger = rootMessengerKey.currentState;
      if (messenger == null) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: content,
          backgroundColor: background,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: margin,
          padding: padding,
          dismissDirection: isDismissible
              ? DismissDirection.down
              : DismissDirection.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ));
      return;
    }

    _TopSnackbar.show(
      overlay: _navigator.overlay,
      background: background,
      duration: duration,
      margin: margin,
      padding: padding,
      borderRadius: borderRadius,
      isDismissible: isDismissible,
      child: content,
    );
  }
}

class _SnackContent extends StatelessWidget {
  final String title;
  final String message;
  final Color colorText;
  final Widget? icon;
  final Widget? titleText;
  final Widget? messageText;

  const _SnackContent({
    required this.title,
    required this.message,
    required this.colorText,
    this.icon,
    this.titleText,
    this.messageText,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = titleText != null || title.isNotEmpty;
    final hasMessage = messageText != null || message.isNotEmpty;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle)
          titleText ??
              Text(title,
                  style: TextStyle(
                      color: colorText,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
        if (hasTitle && hasMessage) const SizedBox(height: 2),
        if (hasMessage)
          messageText ??
              Text(message, style: TextStyle(color: colorText, fontSize: 14)),
      ],
    );
    if (icon == null) return text;
    return Row(
      children: [
        icon!,
        const SizedBox(width: 12),
        Expanded(child: text),
      ],
    );
  }
}

/// A snackbar pinned to the top of the screen, drawn in the root overlay.
/// Only one is visible at a time, like GetX.
abstract final class _TopSnackbar {
  static OverlayEntry? _current;
  static Timer? _timer;

  static void _hide() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }

  static void show({
    required OverlayState? overlay,
    required Color background,
    required Duration duration,
    required EdgeInsets margin,
    required EdgeInsets padding,
    required double borderRadius,
    required bool isDismissible,
    required Widget child,
  }) {
    if (overlay == null) return;
    _hide();
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Padding(
            padding: margin,
            child: Material(
              color: background,
              elevation: 6,
              borderRadius: BorderRadius.circular(borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: isDismissible ? _hide : null,
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ),
      ),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(duration, _hide);
  }
}
