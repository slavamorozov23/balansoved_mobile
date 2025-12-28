import 'package:dartz/dartz.dart';

abstract class IAuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<Unit> cacheAccessToken(String token);
  Future<Unit> clearAccessToken();
}
