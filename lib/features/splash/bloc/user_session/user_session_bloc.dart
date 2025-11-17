import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/local/local_services.dart';
import '../../../profile/repo/profile_repo.dart';
import 'user_session_event.dart';
import 'user_session_state.dart';

class UserSessionBloc extends Bloc<UserSessionEvent, UserSessionState> {
  final ProfileRepository profileRepository;

  UserSessionBloc({required this.profileRepository}) : super(SessionInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignedOut>(_onAuthSignedOut);
  }

  // Event to check if user is already authenticated
  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<UserSessionState> emit) async {
    emit(SessionLoading());

    try {
      // Check if token exists
      String? token = await LocalService.getUserToken();
      if (token == null) {
        emit(SessionUnauthenticated());
        return;
      }

      // Call API to fetch user details
      final result = await profileRepository.getProfile();

      if (result.isSuccess && result.data != null) {
        // Determine if user is driver from profile data
        final userTypeName = result.data!.userType?.name.toLowerCase() ?? '';
        final isDriver = userTypeName == 'driver';
        
        // Update local storage with correct driver flag
        await LocalService.saveToken(accessToken: token, isDriver: isDriver);
        
        emit(SessionAuthenticated(isDriver: isDriver));
      } else {
        // API call failed - clear tokens and go to welcome screen
        await LocalService.deleteTokens();
        emit(SessionUnauthenticated());
      }
    } catch (e) {
      // On error, clear tokens and go to welcome screen
      await LocalService.deleteTokens();
      emit(SessionUnauthenticated());
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
