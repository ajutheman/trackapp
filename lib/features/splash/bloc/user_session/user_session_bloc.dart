import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/local/local_services.dart';
import 'user_session_event.dart';
import 'user_session_state.dart';

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  UserSessionBloc() : super(SessionInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignedOut>(_onAuthSignedOut);
  }

  // Event to check if user is already authenticated
  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<UserSessionState> emit) async {
    emit(SessionLoading());
    await Future.delayed(Duration(milliseconds: 500));

    try {
      // final userToken = await LocalService.getUserToken();
      // if (userToken != null) {
      //   final Result<User> user = await repository.getUser();
      //   if (user.isSuccess && user.data != null) {
      //     emit(SessionAuthenticated(user: user.data!));
      //   } else {
      //     emit(SessionUnauthenticated());
      //   }
      // } else {
      //   emit(SessionUnauthenticated());
      // }
      String? token = await LocalService.getUserToken();
      bool? isDriver = await LocalService.getIsDriver();
      if (token == null) {
        emit(SessionUnauthenticated());
      } else {
        emit(SessionAuthenticated(isDriver: isDriver!));
      }
    } catch (e) {
      emit(SessionError(errorMessage: "Failed to check authentication: $e"));
    }
  }

  // Event to handle sign-out
  void _onAuthSignedOut(AuthSignedOut event, Emitter<UserSessionState> emit) async {
    emit(SessionLoading());

    try {
      await LocalService.deleteTokens();
      emit(SessionUnauthenticated());
    } catch (e) {
      emit(SessionError(errorMessage: "Failed to sign out: $e"));
    }
  }
}
