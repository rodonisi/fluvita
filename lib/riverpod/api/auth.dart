import 'package:fluvita/api/models/login_dto.dart';
import 'package:fluvita/api/models/user_dto.dart';
import 'package:fluvita/api/rest_client.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
Future<UserDto?> currentUser(Ref ref) async {
  final settings = ref.watch(settingsProvider).value;
  final apiKey = settings?.apiKey;

  if (apiKey == null || apiKey.isEmpty) {
    return null;
  }

  final dio = ref.watch(dioProvider);
  final client = RestClient(dio).account;

  final user = await client.postApiAccountLogin(
    body: LoginDto(apiKey: apiKey, username: '', password: ''),
  );

  return user;
}

@riverpod
class Jwt extends _$Jwt {
  @override
  String? build() {
    return ref.watch(currentUserProvider).value?.token;
  }
}
