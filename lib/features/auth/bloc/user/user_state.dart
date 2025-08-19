import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserRegistrationLoading extends UserState {}

class UserRegistrationSuccess extends UserState {}

class UserRegistrationFailure extends UserState {
  final String error;

  const UserRegistrationFailure(this.error);

  @override
  List<Object> get props => [error];
}
