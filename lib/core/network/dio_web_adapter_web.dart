import 'package:dio/dio.dart';
import 'package:dio_web_adapter/dio_web_adapter.dart';

void configureDioForWeb(Dio dio, {required bool withCredentials}) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(
    withCredentials: withCredentials,
  );
}

