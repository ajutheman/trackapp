import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/auth/bloc/auth/auth_bloc.dart';
import 'package:truck_app/features/auth/bloc/image_upload/image_upload_bloc.dart';
import 'package:truck_app/features/auth/bloc/user/user_bloc.dart';
import 'package:truck_app/features/vehicle/bloc/vehicle_metadata/vehicle_meta_bloc.dart';
import 'package:truck_app/features/home/bloc/posts_bloc.dart';
import 'package:truck_app/features/connect/bloc/connect_request_bloc.dart';
import 'package:truck_app/features/post/bloc/customer_request_bloc.dart';

import '../di/locator.dart';
import '../features/connect/bloc/driver_connection_bloc.dart';
import '../features/splash/bloc/user_session/user_session_bloc.dart';
import '../features/vehicle/bloc/vehicle/vehicle_bloc.dart';

List<BlocProvider> globalBlocProviders = [
  BlocProvider<AuthBloc>(create: (_) => locator()),
  BlocProvider<UserSessionBloc>(create: (_) => locator()),
  BlocProvider<UserBloc>(create: (_) => locator()),
  BlocProvider<VehicleBloc>(create: (_) => locator()),
  BlocProvider<VehicleMetaBloc>(create: (_) => locator()),
  BlocProvider<ImageUploadBloc>(create: (_) => locator()),
  BlocProvider<PostsBloc>(create: (_) => locator()),
  BlocProvider<ConnectRequestBloc>(create: (_) => locator()),
  BlocProvider<DriverConnectionBloc>(create: (_) => locator()),
  BlocProvider<CustomerRequestBloc>(create: (_) => locator()),
];
