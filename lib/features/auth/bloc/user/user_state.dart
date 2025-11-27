import 'package:equatable/equatable.dart';
import '../../../../model/network/result.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserRegistrationLoading extends UserState {}

class UserRegistrationSuccess extends UserState {}

class UserRegistrationFailure extends UserState {
  final String error;
  final List<ValidationError>? fieldErrors;

  const UserRegistrationFailure(this.error, {this.fieldErrors});

  /// Check if there are field-specific validation errors
  bool get hasFieldErrors => fieldErrors != null && fieldErrors!.isNotEmpty;

  /// Get error for a specific field
  String? getFieldError(String fieldName) {
    if (fieldErrors == null || fieldErrors!.isEmpty) return null;
    try {
      return fieldErrors!.firstWhere((error) => error.field == fieldName).message;
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [error, fieldErrors];
}
