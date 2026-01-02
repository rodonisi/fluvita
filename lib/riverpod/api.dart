import 'package:laya/riverpod/api/book.dart';
import 'package:laya/riverpod/api/reader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api.g.dart';

@riverpod
Future<String> page(Ref ref, {required int seriesId}) async {
  final chapter = await ref.watch(
    continuePointProvider(seriesId: seriesId).future,
  );

  final progress = await ref.watch(
    bookProgressProvider(chapterId: chapter.id).future,
  );

  return ref.watch(
    bookPageProvider(
      chapterId: progress.chapterId,
      page: progress.pageNum,
    ).future,
  );
}
