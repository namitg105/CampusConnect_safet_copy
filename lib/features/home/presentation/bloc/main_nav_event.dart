part of 'main_nav_bloc.dart';

sealed class MainNavEvent extends Equatable {
  const MainNavEvent();

  @override
  List<Object?> get props => [];
}

/// Bottom-nav tab tapped (0 Home, 1 Community, 2 Upload, 3 Notes,
/// 4 Messages, 5 Profile).
final class MainNavTabSelected extends MainNavEvent {
  final int index;
  const MainNavTabSelected(this.index);

  @override
  List<Object?> get props => [index];
}

/// Messages page tab (index into its IndexedStack: 2 = requests,
/// 3 = directory).
final class PrivateChatTabSelected extends MainNavEvent {
  final int tab;
  const PrivateChatTabSelected(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Back to defaults, e.g. after logout.
final class MainNavReset extends MainNavEvent {
  const MainNavReset();
}
