import 'package:dio/dio.dart';
import 'package:laya/api/rest_client.dart';
import 'package:laya/riverpod/api/auth.dart';
import 'package:laya/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  return dio;
}

@riverpod
Dio authenticatedDio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  final jwt = ref.watch(jwtProvider);

  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (jwt != null && jwt.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $jwt';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

@riverpod
RestClient restClient(Ref ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return RestClient(dio);
}
