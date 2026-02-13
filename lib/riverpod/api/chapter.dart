import 'package:fluvita/models/chapter_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'chapter.g.dart';

@riverpod
@JsonPersist()
class Chapter extends _$Chapter {
  @override
  Future<ChapterModel> build({required int chapterId}) async {
    persist(ref.watch(storageProvider.future));
    final client = ref.watch(restClientProvider);
    final res = await client.apiChapterGet(chapterId: chapterId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load chapter: ${res.error}');
    }

    return ChapterModel.fromChapterDto(res.body!);
  }
}
