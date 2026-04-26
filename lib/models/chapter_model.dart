import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kover/database/app_database.dart';
import 'package:kover/models/enums/format.dart';

part 'chapter_model.freezed.dart';
part 'chapter_model.g.dart';

@freezed
sealed class ChapterModel with _$ChapterModel {
  const ChapterModel._();

  const factory ChapterModel({
    required int id,
    required int seriesId,
    required int volumeId,
    required String title,
    required int pages,
    Format? format,
    String? summary,
    int? wordCount,
    double? avgHoursToRead,
    String? primaryColor,
    String? secondaryColor,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, Object?> json) =>
      _$ChapterModelFromJson(json);

  factory ChapterModel.fromDatabaseModel(Chapter table) {
    return ChapterModel(
      id: table.id,
      seriesId: table.seriesId,
      volumeId: table.volumeId,
      title: _cleanedTitle(table),
      pages: table.pages,
      format: table.format,
      summary: table.summary,
      wordCount: table.wordCount,
      avgHoursToRead: table.avgHoursToRead,
      primaryColor: table.primaryColor,
      secondaryColor: table.secondaryColor,
    );
  }

  static String _cleanedTitle(Chapter table) {
    final titles = [
      table.title,
      table.titleName,
    ].whereType<String>().where((t) => t.trim().isNotEmpty);

    if (titles.isEmpty) {
      return switch (table.format) {
        .epub => 'Book ${table.minNumber}',
        .image || .archive => 'Chapter ${table.minNumber}',
        _ => 'Untitled',
      };
    }

    return titles.join(' - ');
  }
}
