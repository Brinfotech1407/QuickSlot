import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../di/service_locator.dart';
import 'route_names.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SplashCubit>()..start(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<HomeCubit>()..loadItems(),
          child: const HomeScreen(),
        ),
      ),
    ],
  );
}
