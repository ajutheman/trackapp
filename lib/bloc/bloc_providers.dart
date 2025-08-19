import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/features/auth/bloc/auth/auth_bloc.dart';
import 'package:truck_app/features/auth/bloc/user/user_bloc.dart';

import '../di/locator.dart';

List<BlocProvider> globalBlocProviders = [BlocProvider<AuthBloc>(create: (_) => locator()), BlocProvider<UserBloc>(create: (_) => locator())];
