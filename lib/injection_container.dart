/*import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'auth/data/datasources/auth_remote_data_source.dart';
import 'auth/data/datasources/auth_remote_data_source_impl.dart';
import 'auth/data/repositories/auth_repository_impl.dart';
import 'auth/domain/repositories/auth_repository.dart';
import 'auth/presentation/auth_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

void init() {
  // --- Providers ---
  sl.registerFactory(() => AuthProvider(authRepository: sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // --- Data sources ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // --- External ---
  sl.registerLazySingleton(() => Dio());
}

 */
