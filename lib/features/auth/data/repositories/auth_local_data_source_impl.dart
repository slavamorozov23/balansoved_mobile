import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data_source/auth_local_data_source.dart';

const String _cachedTokenKey = 'access_token';

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  final SharedPreferences prefs;
  AuthLocalDataSourceImpl({required this.prefs});

  @override
  Future<String?> getAccessToken() async => prefs.getString(_cachedTokenKey);

  @override
  Future<Unit> cacheAccessToken(String token) async {
    await prefs.setString(_cachedTokenKey, token);
    return unit;
  }

  @override
  Future<Unit> clearAccessToken() async {
    await prefs.remove(_cachedTokenKey);
    return unit;
  }
}
