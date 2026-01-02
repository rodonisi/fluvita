import 'package:freezed_annotation/freezed_annotation.dart';

part 'series_model.freezed.dart';
part 'series_model.g.dart';

@freezed
sealed class SeriesModel with _$SeriesModel {
  const SeriesModel._();

  const factory SeriesModel({
    required int id,
    required int libraryId,
    required String name,
  }) = _SeriesModel;

  factory SeriesModel.fromJson(Map<String, Object?> json) =>
      _$SeriesModelFromJson(json);
}
