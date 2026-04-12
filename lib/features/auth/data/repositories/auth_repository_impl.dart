import 'package:medinear_app/features/auth/domain/entities/user_entity.dart';
import 'package:medinear_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:medinear_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medinear_app/core/services/token_storage.dart';
import 'package:medinear_app/core/services/user_storage.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final UserStorage userStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage, this.userStorage);

  @override
  Future<UserEntity?> loginWithGoogle() async {
    final user = await remoteDataSource.loginWithGoogle();
    if (user != null) {
      await tokenStorage.saveToken(user.token);
      await userStorage.saveUser(user);
      if (kDebugMode) print("✅ Google Token + User Saved");
    }
    return user;
  }

  @override
  Future<UserEntity?> loginWithFacebook() async {
    final user = await remoteDataSource.loginWithFacebook();
    if (user != null) {
      await tokenStorage.saveToken(user.token);
      await userStorage.saveUser(user);
      if (kDebugMode) print("✅ FB Token + User Saved");
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await tokenStorage.clear();
    await userStorage.clear();
    if (kDebugMode) print("🗑️ [Repository] Token + User Cleared");
  }
}