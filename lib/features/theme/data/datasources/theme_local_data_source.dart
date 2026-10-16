import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';

/// Reads/writes the theme flag in the Hive `settings` box (on-device only).
abstract interface class ThemeLocalDataSource {
  bool? readIsLightMode();
  Future<void> writeIsLightMode(bool isLightMode);
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  static const _key = 'isLightMode';
  final Box settingsBox;
  const ThemeLocalDataSourceImpl(this.settingsBox);

  @override
  bool? readIsLightMode() {
    try {
      return settingsBox.get(_key) as bool?;
    } catch (e) {
      throw CacheException('Could not read theme: $e');
    }
  }

  @override
  Future<void> writeIsLightMode(bool isLightMode) async {
    try {
      await settingsBox.put(_key, isLightMode);
    } catch (e) {
      throw CacheException('Could not save theme: $e');
    }
  }
}
