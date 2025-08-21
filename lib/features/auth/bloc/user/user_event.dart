import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class RegisterUser extends UserEvent {
  final String userType;
  final String name;
  final String whatsappNumber;
  final String email;
  final String token;

  const RegisterUser({required this.userType, required this.name, required this.whatsappNumber, required this.email, required this.token});

  @override
  List<Object> get props => [name, whatsappNumber, email, token];
}
