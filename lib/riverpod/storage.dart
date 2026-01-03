import 'package:fluvita/services/persistence.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage.g.dart';

@riverpod
Future<Storage<String, String>> storage(Ref ref) async {
  await Persistence.initialize();
  return Persistence();
}
