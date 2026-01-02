import 'package:laya/api/models/library_dto.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library.g.dart';

@riverpod
Future<List<LibraryDto>> libraries(Ref ref) async {
  final client = ref.watch(restClientProvider).library;
  return await client.getApiLibraryLibraries();
}
