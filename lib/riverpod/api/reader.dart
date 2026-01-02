import 'package:laya/api/models/chapter_dto.dart';
import 'package:laya/api/models/progress_dto.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reader.g.dart';

@riverpod
Future<ChapterDto> continuePoint(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderContinuePoint(seriesId: seriesId);
}

@riverpod
Future<ProgressDto> bookProgress(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderGetProgress(chapterId: chapterId);
}
