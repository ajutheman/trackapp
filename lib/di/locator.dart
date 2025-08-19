import 'package:get_it/get_it.dart';
import 'package:truck_app/features/auth/bloc/auth_bloc.dart';

import '../features/auth/repo/auth_repo.dart';
import '../services/network/api_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core services
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  locator.registerLazySingleton(() => AuthRepository(apiService: locator()));

  // BLoCs
  locator.registerFactory(() => AuthBloc(repository: locator()));
}
