import 'package:flutter_test/flutter_test.dart';
import 'package:noteswap/features/home/presentation/bloc/main_nav_bloc.dart';

void main() {
  late MainNavBloc bloc;
  setUp(() => bloc = MainNavBloc());
  tearDown(() => bloc.close());

  test('starts on Home tab and first Messages tab', () {
    expect(bloc.state, const MainNavState(currentIndex: 0, privateChatTab: 0));
  });

  test('selecting a bottom tab keeps the Messages tab', () async {
    bloc
      ..add(const PrivateChatTabSelected(2))
      ..add(const MainNavTabSelected(4));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const MainNavState(privateChatTab: 2),
        const MainNavState(currentIndex: 4, privateChatTab: 2),
      ]),
    );
  });

  test('reset goes back to defaults (logout)', () async {
    bloc
      ..add(const MainNavTabSelected(3))
      ..add(const MainNavReset());
    await expectLater(
      bloc.stream,
      emitsInOrder([
        const MainNavState(currentIndex: 3),
        const MainNavState(),
      ]),
    );
  });
}
