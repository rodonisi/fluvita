import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:laya/riverpod/api/auth.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image.g.dart';

@riverpod
Future<Uint8List> coverImage(Ref ref, {required int seriesId}) async {
  final dio = ref.watch(authenticatedDioProvider);
  final key = ref.watch(currentUserProvider).value?.apiKey;

  final res = await dio.get(
    '/api/Image/series-cover',
    queryParameters: {
      'seriesId': seriesId,
      'apiKey': key,
    },
    options: Options(
      responseType: .bytes,
      headers: {
        'Accept': 'image/*',
      },
    ),
  );

  return res.data;
}
