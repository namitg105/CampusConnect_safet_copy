import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/core/navigation/app_navigator.dart';

Widget _app() => MaterialApp(
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootMessengerKey,
      home: const Scaffold(body: Text('home')),
    );

Widget _page(String label) => Scaffold(body: Text(label));

void main() {
  testWidgets('push then pop returns to the previous screen', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.push(_page('second'));
    await tester.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);

    AppNavigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('second'), findsNothing);
  });

  testWidgets('push returns the result passed to pop', (tester) async {
    await tester.pumpWidget(_app());
    final future = AppNavigator.push<String>(_page('picker'));
    await tester.pumpAndSettle();
    AppNavigator.pop('picked');
    await tester.pumpAndSettle();
    expect(await future, 'picked');
  });

  testWidgets('replace swaps the top screen', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.push(_page('a'));
    await tester.pumpAndSettle();
    AppNavigator.replace(_page('b'));
    await tester.pumpAndSettle();
    AppNavigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('replaceAll clears the stack', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.push(_page('a'));
    await tester.pumpAndSettle();
    AppNavigator.replaceAll(_page('root'));
    await tester.pumpAndSettle();
    expect(rootNavigatorKey.currentState!.canPop(), isFalse);
    expect(find.text('root'), findsOneWidget);
  });

  testWidgets('popTimes closes dialog and screen together', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.push(_page('preview'));
    await tester.pumpAndSettle();
    AppNavigator.showAppDialog(const Text('loading'),
        barrierDismissible: false);
    await tester.pumpAndSettle();
    expect(find.text('loading'), findsOneWidget);

    AppNavigator.popTimes(2);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('top snackbar shows and auto-hides', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.showSnackbar('Saved', 'Profile updated',
        duration: const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Profile updated'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('bottom snackbar uses ScaffoldMessenger', (tester) async {
    await tester.pumpWidget(_app());
    AppNavigator.showSnackbar('Error', 'Upload failed',
        snackPosition: SnackPosition.bottom);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Upload failed'), findsOneWidget);
  });
}
