import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/core/error/exceptions.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import 'package:noteswap/features/theme/data/datasources/theme_local_data_source.dart';
import 'package:noteswap/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:noteswap/features/theme/domain/usecases/get_saved_theme.dart';
import 'package:noteswap/features/theme/domain/usecases/save_theme.dart';
import 'package:noteswap/features/theme/presentation/bloc/theme_bloc.dart';

/// In-memory stand-in for the Hive box.
class FakeThemeLocalDataSource implements ThemeLocalDataSource {
  bool? stored;
  bool failReads = false;

  @override
  bool? readIsLightMode() {
    if (failReads) throw const CacheException('disk error');
    return stored;
  }

  @override
  Future<void> writeIsLightMode(bool isLightMode) async => stored = isLightMode;
}

ThemeBloc _bloc(FakeThemeLocalDataSource source) {
  final repo = ThemeRepositoryImpl(source);
  return ThemeBloc(getSavedTheme: GetSavedTheme(repo), saveTheme: SaveTheme(repo));
}

void main() {
  test('defaults to light mode when nothing is saved', () {
    expect(_bloc(FakeThemeLocalDataSource()).state.isLightMode, isTrue);
  });

  test('starts with the saved value', () {
    final source = FakeThemeLocalDataSource()..stored = false;
    expect(_bloc(source).state.isLightMode, isFalse);
  });

  test('falls back to light mode when storage cannot be read', () {
    final source = FakeThemeLocalDataSource()..failReads = true;
    expect(_bloc(source).state.isLightMode, isTrue);
  });

  test('toggle flips the mode and saves it', () async {
    final source = FakeThemeLocalDataSource();
    final bloc = _bloc(source)..add(const ThemeToggled());
    await expectLater(
        bloc.stream, emits(const ThemeState(isLightMode: false)));
    await Future<void>.delayed(Duration.zero);
    expect(source.stored, isFalse);
    await bloc.close();
  });

  testWidgets('context.isLightMode follows ThemeBloc', (tester) async {
    final bloc = _bloc(FakeThemeLocalDataSource());
    addTearDown(() => tester.runAsync(bloc.close));
    await tester.pumpWidget(BlocProvider.value(
      value: bloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (_, state) => MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: state.isLightMode ? ThemeMode.light : ThemeMode.dark,
          home: Builder(
            builder: (context) =>
                Text(context.isLightMode ? 'light' : 'dark'),
          ),
        ),
      ),
    ));
    expect(find.text('light'), findsOneWidget);

    bloc.add(const ThemeToggled());
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsOneWidget);
  });
}
