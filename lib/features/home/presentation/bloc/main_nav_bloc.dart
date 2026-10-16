import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_nav_event.dart';
part 'main_nav_state.dart';

/// Which bottom-nav tab is open, and which tab of the Messages page.
/// Pure UI state, so there is no domain/data layer behind it (YAGNI).
class MainNavBloc extends Bloc<MainNavEvent, MainNavState> {
  MainNavBloc() : super(const MainNavState()) {
    on<MainNavTabSelected>(
      (event, emit) => emit(state.copyWith(currentIndex: event.index)),
    );
    on<PrivateChatTabSelected>(
      (event, emit) => emit(state.copyWith(privateChatTab: event.tab)),
    );
    on<MainNavReset>((event, emit) => emit(const MainNavState()));
  }
}
