import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/presentation/cubit/booking_cubit.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../network/api_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/local_storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  sl
    ..registerLazySingleton<LocalStorageService>(() => localStorageService)
    ..registerLazySingleton<ApiInterceptor>(
      () => ApiInterceptor(sl<LocalStorageService>()),
    )
    ..registerLazySingleton<Dio>(
      () => DioClient.create(sl<ApiInterceptor>()),
    )
    ..registerLazySingleton<DioClient>(
      () => DioClient(sl<Dio>()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl<DioClient>()),
    )
    ..registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(sl<DioClient>()),
    )
    ..registerFactory<SplashCubit>(SplashCubit.new)
    ..registerFactory<HomeCubit>(
      () => HomeCubit(sl<HomeRepository>()),
    )
    ..registerFactory<BookingCubit>(
      () => BookingCubit(
        sl<BookingRepository>(),
        sl<LocalStorageService>(),
      ),
    );
}
