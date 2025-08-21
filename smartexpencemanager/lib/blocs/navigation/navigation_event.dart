import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class UpdateNavigationIndex extends NavigationEvent {
  final int newIndex;

  const UpdateNavigationIndex(this.newIndex);

  @override
  List<Object> get props => [newIndex];
}
