import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<UpdateNavigationIndex>(_onUpdateNavigationIndex);
  }

  void _onUpdateNavigationIndex(
    UpdateNavigationIndex event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.newIndex));
  }
}
