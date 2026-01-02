import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laya/api/models/recently_added_item_dto.dart';
import 'package:laya/api/models/series_dto.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

enum Format { epub, cbz, unknown }

@freezed
sealed class SeriesModel with _$SeriesModel {
  const SeriesModel._();

  const factory SeriesModel({
    required int id,
    required int libraryId,
    required String name,
    required Format format,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, Object?> json) =>
      _$SeriesModelFromJson(json);

  factory SeriesModel.fromSeriesDto(SeriesDto dto) {
    return SeriesModel(
      id: dto.id,
      libraryId: dto.libraryId,
      name: dto.name ?? 'Untitled',
      format: switch (dto.format) {
        .value3 => Format.epub,
        .value1 => Format.cbz,
        _ => Format.unknown,
      },
    );
  }

  factory SeriesModel.fromRecentlyAddedItemDto(RecentlyAddedItemDto dto) {
    return SeriesModel(
      id: dto.seriesId,
      libraryId: dto.libraryId,
      name: dto.seriesName ?? 'Untitled',
      format: switch (dto.format) {
        .value3 => Format.epub,
        .value1 => Format.cbz,
        _ => Format.unknown,
      },
    );
  }
}
