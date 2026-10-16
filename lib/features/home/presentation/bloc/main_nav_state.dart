part of 'main_nav_bloc.dart';

final class MainNavState extends Equatable {
  final int currentIndex;
  final int privateChatTab;

  const MainNavState({this.currentIndex = 0, this.privateChatTab = 0});

  MainNavState copyWith({int? currentIndex, int? privateChatTab}) {
    return MainNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      privateChatTab: privateChatTab ?? this.privateChatTab,
    );
  }

  @override
  List<Object?> get props => [currentIndex, privateChatTab];
}
