import 'package:get_it/get_it.dart';
import 'package:truck_app/features/auth/bloc/auth/auth_bloc.dart';
import 'package:truck_app/features/auth/bloc/user/user_bloc.dart';
import 'package:truck_app/features/auth/repo/user_repo.dart';

import '../features/auth/repo/auth_repo.dart';
import '../services/network/api_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core services
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  locator.registerLazySingleton(() => AuthRepository(apiService: locator()));
  locator.registerLazySingleton(() => UserRepository(apiService: locator()));

  // BLoCs
  locator.registerFactory(() => AuthBloc(repository: locator()));
  locator.registerFactory(() => UserBloc(repository: locator()));
}
