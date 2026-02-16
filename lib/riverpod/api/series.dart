import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/repository/series_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Stream<SeriesModel> series(Ref ref, {required int seriesId}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchSeries(seriesId);
}

@riverpod
Stream<List<SeriesModel>> allSeries(Ref ref, {int? libraryId}) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchAllSeries(libraryId: libraryId);
}

@riverpod
class SeriesDetail extends _$SeriesDetail {
  @override
  Future<SeriesDetailModel> build({required int seriesId}) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesSeriesDetailGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series detail: ${res.error}');
    }

    return SeriesDetailModel.fromSeriesDetailDto(res.body!);
  }
}

@riverpod
class SeriesMetadata extends _$SeriesMetadata {
  @override
  Future<SeriesMetadataModel> build({
    required int seriesId,
  }) async {
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesMetadataGet(seriesId: seriesId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load series metadata: ${res.error}');
    }

    return SeriesMetadataModel.fromSeriesMetadataDto(res.body!);
  }
}

@riverpod
Stream<List<SeriesModel>> onDeck(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchOnDeck();
}

@riverpod
Stream<List<SeriesModel>> recentlyUpdated(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchRecentlyUpdated();
}

@riverpod
Stream<List<SeriesModel>> recentlyAdded(Ref ref) async* {
  final repo = ref.watch(seriesRepositoryProvider);
  yield* repo.watchRecentlyAdded();
}
