abstract class UserSessionState {}

class SessionInitial extends UserSessionState {}

class SessionLoading extends UserSessionState {}

class SessionAuthenticated extends UserSessionState {
  final bool isDriver;

  SessionAuthenticated({required this.isDriver});
}

class SessionUnauthenticated extends UserSessionState {}

class SessionError extends UserSessionState {
  final String errorMessage;

  SessionError({required this.errorMessage});
}
