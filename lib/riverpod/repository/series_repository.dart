import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

/// Database provider
@riverpod
AppDatabase database(Ref ref) {
  return AppDatabase();
}

class SeriesRepository {
  final AppDatabase _db;
  final Openapi _client;

  const SeriesRepository(this._db, this._client);

  Stream<List<Sery>> watchOnDeck() {
    _refreshedOnDeck();
    return _db.watchOnDeck();
  }

  Future<void> _refreshedOnDeck() async {
    final res = await _client.apiSeriesOnDeckPost();

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load on deck: ${res.error}');
    }

    await _db.upsertSeriesBatch(res.body!.map(_mapSeriesCompanion));
    await _db.updateOnDeck(
      res.body!.map((dto) => OnDeckData(seriesId: dto.id!)),
    );
  }

  SeriesCompanion _mapSeriesCompanion(SeriesDto dto) {
    return SeriesCompanion(
      id: Value(dto.id!),
      name: Value(dto.name!),
      originalName: Value(dto.originalName),
      localizedName: Value(dto.localizedName),
      sortName: Value(dto.sortName!),
      libraryId: Value(dto.libraryId!),
      format: Value(Format.fromDtoFormat(dto.format!)),
      pages: Value(dto.pages!),
      wordCount: Value(dto.wordCount ?? 0),
      avgHoursToRead: Value(dto.avgHoursToRead),
      coverImageUrl: Value(dto.coverImage),
      primaryColor: Value(dto.primaryColor),
      secondaryColor: Value(dto.secondaryColor),
      pagesRead: Value(dto.pagesRead!),
      created: Value(dto.created!),
      lastModified: Value(DateTime.now()),
      lastChapterAdded: Value(dto.lastChapterAddedUtc),
      lastRead: Value(dto.latestReadDate),
    );
  }
}
