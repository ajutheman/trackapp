import 'package:get_it/get_it.dart';
import 'package:truck_app/features/auth/bloc/auth/auth_bloc.dart';
import 'package:truck_app/features/auth/bloc/user/user_bloc.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';
import 'package:truck_app/features/auth/repo/user_repo.dart';
import 'package:truck_app/features/vehicle/repo/vehicle_metadata_repo.dart';
import 'package:truck_app/features/vehicle/repo/vehicle_repo.dart';
import 'package:truck_app/features/splash/bloc/user_session/user_session_bloc.dart';
import 'package:truck_app/features/home/repo/posts_repo.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/connect/repo/connect_request_repo.dart';
import 'package:truck_app/features/connect/bloc/connect_request_bloc.dart';
import 'package:truck_app/features/post/repo/customer_request_repo.dart';
import 'package:truck_app/features/post/bloc/customer_request_bloc.dart';
import 'package:truck_app/features/token/repo/token_repo.dart';
import 'package:truck_app/features/token/bloc/token_bloc.dart';
import 'package:truck_app/features/profile/repo/profile_repo.dart';
import 'package:truck_app/features/booking/repo/booking_repo.dart';
import 'package:truck_app/features/booking/bloc/booking_bloc.dart';
import 'package:truck_app/features/review/repo/review_repo.dart';
import 'package:truck_app/features/review/bloc/review_bloc.dart';

import '../features/auth/bloc/image_upload/image_upload_bloc.dart';
import '../features/auth/repo/auth_repo.dart';
import '../features/connect/bloc/driver_connection_bloc.dart';
import '../features/connect/repo/driver_connection_repo.dart';
import '../features/notification/repo/notification_repository.dart';
import '../features/vehicle/bloc/vehicle/vehicle_bloc.dart';
import '../features/vehicle/bloc/vehicle_metadata/vehicle_meta_bloc.dart';
import '../services/network/api_service.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Core services
  locator.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  locator.registerLazySingleton(() => AuthRepository(apiService: locator()));
  locator.registerLazySingleton(() => UserRepository(apiService: locator()));
  locator.registerLazySingleton(() => VehicleRepository(apiService: locator()));
  locator.registerLazySingleton(
    () => VehicleMetaRepository(apiService: locator()),
  );
  locator.registerLazySingleton(
    () => ImageUploadRepository(apiService: locator()),
  );
  locator.registerLazySingleton(() => PostsRepository(apiService: locator()));
  locator.registerLazySingleton(
    () => ConnectRequestRepository(apiService: locator()),
  );
  locator.registerLazySingleton(
    () => DriverConnectionRepository(apiService: locator()),
  );
  locator.registerLazySingleton(
    () => CustomerRequestRepository(apiService: locator()),
  );
  locator.registerLazySingleton(() => TokenRepository(apiService: locator()));
  locator.registerLazySingleton(() => ProfileRepository(apiService: locator()));
  locator.registerLazySingleton(() => BookingRepository(apiService: locator()));
  locator.registerLazySingleton(() => ReviewRepository(apiService: locator()));
  locator.registerLazySingleton(
    () => NotificationRepository(apiService: locator()),
  );

  // BLoCs
  locator.registerFactory(() => AuthBloc(repository: locator()));
  locator.registerFactory(() => UserSessionBloc(profileRepository: locator()));
  locator.registerFactory(() => UserBloc(repository: locator()));
  locator.registerFactory(
    () => VehicleBloc(repository: locator(), imageRepository: locator()),
  );
  locator.registerFactory(() => VehicleMetaBloc(repository: locator()));
  locator.registerFactory(() => ImageUploadBloc(repository: locator()));
  locator.registerFactory(() => PostsBloc(repository: locator()));
  locator.registerFactory(() => ConnectRequestBloc(repository: locator()));
  locator.registerFactory(() => DriverConnectionBloc(repository: locator()));
  locator.registerFactory(() => CustomerRequestBloc(repository: locator()));
  locator.registerFactory(() => TokenBloc(repository: locator()));
  locator.registerFactory(() => BookingBloc(repository: locator()));
  locator.registerFactory(() => ReviewBloc(repository: locator()));
}
