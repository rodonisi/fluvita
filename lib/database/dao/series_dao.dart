import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:stream_transform/stream_transform.dart';

part 'series_dao.g.dart';

@DriftAccessor(tables: [Series, SeriesCovers])
class SeriesDao extends DatabaseAccessor<AppDatabase> with _$SeriesDaoMixin {
  SeriesDao(super.attachedDatabase);

  Stream<SeriesData> watchSeries(int seriesId) {
    return (select(
      series,
    )..where((row) => row.id.equals(seriesId))).watchSingle();
  }

  Stream<List<SeriesData>> watchAllSeries({int? libraryId}) {
    final query = select(series);
    if (libraryId != null) {
      return (query..where((row) => row.libraryId.equals(libraryId))).watch();
    }

    return query.watch();
  }

  Stream<List<SeriesData>> watchOnDeck() {
    return (select(series)
          ..where((row) => row.isOnDeck)
          ..orderBy([(t) => OrderingTerm.desc(t.lastRead)]))
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyUpdated() {
    return (select(series)
          ..where((row) => row.isRecentlyUpdated)
          ..orderBy([(t) => OrderingTerm.desc(t.lastChapterAdded)]))
        .watch();
  }

  Stream<List<SeriesData>> watchRecentlyAdded() {
    return (select(series)
          ..where((row) => row.isRecentlyAdded)
          ..orderBy([(t) => OrderingTerm.desc(t.created)]))
        .watch();
  }

  Stream<SeriesCover> watchSeriesCover({required int seriesId}) {
    return (select(
          seriesCovers,
        )..where((row) => row.seriesId.equals(seriesId)))
        .watchSingleOrNull()
        .whereNotNull();
  }

  Future<void> upsertSeries(SeriesCompanion entry) async {
    log.d('upserting series ${entry.id.value}');
    await into(series).insertOnConflictUpdate(entry);
  }

  Future<void> upsertSeriesBatch(Iterable<SeriesCompanion> entries) async {
    log.d('upserting series batch with ${entries.length} entries');
    await batch((batch) {
      batch.insertAllOnConflictUpdate(series, entries);
    });
  }

  Future<void> upsertOnDeck(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearOnDeck();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertRecentlyUpdated(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearIsRecentlyUpdated();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertRecentlyAdded(Iterable<SeriesCompanion> entries) async {
    await transaction(() async {
      await clearIsRecentlyAdded();
      await upsertSeriesBatch(entries);
    });
  }

  Future<void> upsertSeriesCover(SeriesCoversCompanion cover) async {
    await into(seriesCovers).insertOnConflictUpdate(cover);
  }

  Future<void> clearOnDeck() async {
    await (update(series)..where((row) => row.isOnDeck)).write(
      const SeriesCompanion(isOnDeck: Value(false)),
    );
  }

  Future<void> clearIsRecentlyUpdated() async {
    await (update(series)..where((row) => row.isRecentlyUpdated)).write(
      const SeriesCompanion(isRecentlyUpdated: Value(false)),
    );
  }

  Future<void> clearIsRecentlyAdded() async {
    await (update(series)..where((row) => row.isRecentlyAdded)).write(
      const SeriesCompanion(isRecentlyAdded: Value(false)),
    );
  }
}
