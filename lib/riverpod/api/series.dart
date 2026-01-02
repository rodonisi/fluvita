import 'package:laya/api/models/filter_statement_dto.dart';
import 'package:laya/api/models/filter_v2_dto.dart';
import 'package:laya/api/models/recently_added_item_dto.dart';
import 'package:laya/api/models/series_detail_dto.dart';
import 'package:laya/api/models/series_dto.dart';
import 'package:laya/api/models/sort_options.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series.g.dart';

@riverpod
Future<List<SeriesDto>> series(Ref ref, int libraryId) async {
  final client = ref.watch(restClientProvider).series;
  return await client.postApiSeriesV2(
    body: FilterV2Dto(
      id: 0,
      combination: .value0,
      sortOptions: SortOptions(sortField: .value1, isAscending: false),
      limitTo: 20,
      statements: [
        FilterStatementDto(
          comparison: .value0,
          field: .value19,
          value: libraryId.toString(),
        ),
      ],
    ),
  );
}

@riverpod
Future<SeriesDetailDto> seriesDetail(Ref ref, int seriesID) async {
  final client = ref.watch(restClientProvider).series;
  return await client.getApiSeriesSeriesDetail(seriesId: seriesID);
}

@riverpod
Future<List<SeriesModel>> onDeck(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesOnDeck();
  return res.map(_seriesDtoToSeriesModel).toList();
}

@riverpod
Future<List<SeriesModel>> recentlyUpdated(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesRecentlyUpdatedSeries();
  return res.map(_recentlyAddedItemDtoToSeriesModel).toList();
}

@riverpod
Future<List<SeriesModel>> recentlyAdded(Ref ref) async {
  final client = ref.watch(restClientProvider).series;
  final res = await client.postApiSeriesRecentlyAddedV2();
  return res.map(_seriesDtoToSeriesModel).toList();
}

SeriesModel _seriesDtoToSeriesModel(SeriesDto dto) {
  return SeriesModel(
    id: dto.id,
    libraryId: dto.libraryId,
    name: dto.name ?? 'Untitled',
  );
}

SeriesModel _recentlyAddedItemDtoToSeriesModel(RecentlyAddedItemDto dto) {
  return SeriesModel(
    id: dto.seriesId,
    libraryId: dto.libraryId,
    name: dto.seriesName ?? 'Untitled',
  );
}
