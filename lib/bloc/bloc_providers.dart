import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/auth/bloc/auth/auth_bloc.dart';
import 'package:truck_app/features/auth/bloc/image_upload/image_upload_bloc.dart';
import 'package:truck_app/features/auth/bloc/user/user_bloc.dart';

import '../di/locator.dart';
import '../features/auth/bloc/vehicle/vehicle_bloc.dart';
import '../features/splash/bloc/user_session/user_session_bloc.dart';

List<BlocProvider> globalBlocProviders = [
  BlocProvider<AuthBloc>(create: (_) => locator()),
  BlocProvider<UserSessionBloc>(create: (_) => locator()),
  BlocProvider<UserBloc>(create: (_) => locator()),
  BlocProvider<VehicleBloc>(create: (_) => locator()),
  BlocProvider<ImageUploadBloc>(create: (_) => locator()),
];
