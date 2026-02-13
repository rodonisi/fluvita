import 'package:fluvita/models/library_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'library.g.dart';

@riverpod
@JsonPersist()
class Library extends _$Library {
  @override
  Future<LibraryModel> build({required int libraryId}) async {
    persist(ref.watch(storageProvider.future));

    final client = ref.watch(restClientProvider);
    final res = await client.apiLibraryGet(libraryId: libraryId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load library: ${res.error}');
    }

    return LibraryModel.fromLibraryDto(res.body!);
  }
}

@riverpod
@JsonPersist()
class Libraries extends _$Libraries {
  @override
  Future<List<LibraryModel>> build() async {
    persist(ref.watch(storageProvider.future));
    final client = ref.watch(restClientProvider);
    final res = await client.apiLibraryLibrariesGet();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load libraries: ${res.error}');
    }

    return res.body!.map(LibraryModel.fromLibraryDto).toList();
  }
}
