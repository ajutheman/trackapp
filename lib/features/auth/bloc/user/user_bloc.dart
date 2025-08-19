import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/app_user_type.dart';

import '../../../../services/local/local_services.dart';
import '../../repo/user_repo.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(UserInitial()) {
    on<RegisterUser>(_onRegisterUser);
  }

  void _onRegisterUser(RegisterUser event, Emitter<UserState> emit) async {
    emit(UserRegistrationLoading());
    final result = await repository.createProfile(name: event.name, whatsappNumber: event.whatsappNumber, email: event.email, userType: AppUserType.user, token: event.token);
    String token = result.data?['accessToken'] ?? '';
    await LocalService.saveToken(accessToken: token);
    if (result.isSuccess) {
      emit(UserRegistrationSuccess());
    } else {
      emit(UserRegistrationFailure(result.message!));
    }
  }
}
