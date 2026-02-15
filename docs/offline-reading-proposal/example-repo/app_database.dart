// Example: lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fluvita/database/tables.dart';
import 'package:fluvita/utils/safe_platform.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Series,
  Chapters,
  Volumes,
  DownloadedPages,
  PendingSyncOperations,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ═══════════════════════════════════════════════════
  // SERIES QUERIES
  // ═══════════════════════════════════════════════════

  /// Watch single series (reactive - auto-updates UI)
  Stream<SeriesData?> watchSeries(int seriesId) {
    return (select(series)..where((s) => s.id.equals(seriesId)))
        .watchSingleOrNull();
  }

  /// Get single series (one-time read)
  Future<SeriesData?> getSeries(int seriesId) {
    return (select(series)..where((s) => s.id.equals(seriesId)))
        .getSingleOrNull();
  }

  /// Watch all series (optionally filtered by library)
  Stream<List<SeriesData>> watchAllSeries({int? libraryId}) {
    final query = select(series);
    if (libraryId != null) {
      query.where((s) => s.libraryId.equals(libraryId));
    }
    query.orderBy([
      (s) => OrderingTerm.desc(s.lastModified),
    ]);
    return query.watch();
  }

  /// Watch downloaded series
  Stream<List<SeriesData>> watchDownloadedSeries() {
    return (select(series)..where((s) => s.isDownloaded.equals(true)))
        .watch();
  }

  /// Watch recently read series
  Stream<List<SeriesData>> watchRecentlyRead({int limit = 10}) {
    return (select(series)
          ..where((s) => s.lastRead.isNotNull())
          ..orderBy([
            (s) => OrderingTerm.desc(s.lastRead),
          ])
          ..limit(limit))
        .watch();
  }

  /// Upsert series (insert or update)
  Future<void> upsertSeries(SeriesCompanion entry) async {
    await into(series).insertOnConflictUpdate(entry);
  }

  /// Batch upsert multiple series
  Future<void> upsertSeriesBatch(List<SeriesCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(series, entries);
    });
  }

  /// Mark series as downloaded
  Future<void> markSeriesDownloaded(int seriesId, bool isDownloaded) async {
    await (update(series)..where((s) => s.id.equals(seriesId))).write(
      SeriesCompanion(
        isDownloaded: Value(isDownloaded),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update series progress
  Future<void> updateSeriesProgress(
    int seriesId, {
    required int pagesRead,
    required double progress,
  }) async {
    await (update(series)..where((s) => s.id.equals(seriesId))).write(
      SeriesCompanion(
        pagesRead: Value(pagesRead),
        progress: Value(progress),
        lastRead: Value(DateTime.now()),
      ),
    );
  }

  /// Check if data is stale (older than duration)
  Future<bool> isSeriesStale(int seriesId, Duration maxAge) async {
    final data = await getSeries(seriesId);
    if (data == null) return true;
    
    final age = DateTime.now().difference(data.cachedAt);
    return age > maxAge;
  }

  // ═══════════════════════════════════════════════════
  // CHAPTER QUERIES
  // ═══════════════════════════════════════════════════

  /// Watch chapters for a series
  Stream<List<ChaptersData>> watchChaptersForSeries(int seriesId) {
    return (select(chapters)
          ..where((c) => c.seriesId.equals(seriesId))
          ..orderBy([
            (c) => OrderingTerm.asc(c.volumeNumber),
            (c) => OrderingTerm.asc(c.minNumber),
          ]))
        .watch();
  }

  /// Get single chapter
  Future<ChaptersData?> getChapter(int chapterId) {
    return (select(chapters)..where((c) => c.id.equals(chapterId)))
        .getSingleOrNull();
  }

  /// Upsert chapter
  Future<void> upsertChapter(ChaptersCompanion entry) async {
    await into(chapters).insertOnConflictUpdate(entry);
  }

  /// Batch upsert chapters
  Future<void> upsertChaptersBatch(List<ChaptersCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(chapters, entries);
    });
  }

  /// Mark chapter as downloaded
  Future<void> markChapterDownloaded(int chapterId, bool isDownloaded) async {
    await (update(chapters)..where((c) => c.id.equals(chapterId))).write(
      ChaptersCompanion(
        isDownloaded: Value(isDownloaded),
        cachedAt: Value(DateTime.now()),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // SYNC QUEUE
  // ═══════════════════════════════════════════════════

  /// Add operation to sync queue
  Future<int> enqueueSyncOperation({
    required String operationType,
    required String payload,
  }) async {
    return await into(pendingSyncOperations).insert(
      PendingSyncOperationsCompanion.insert(
        operationType: operationType,
        payload: payload,
      ),
    );
  }

  /// Get all pending sync operations
  Future<List<PendingSyncOperationsData>> getPendingSyncOperations() {
    return (select(pendingSyncOperations)
          ..orderBy([
            (o) => OrderingTerm.asc(o.createdAt),
          ]))
        .get();
  }

  /// Remove sync operation after successful execution
  Future<void> removeSyncOperation(int id) async {
    await (delete(pendingSyncOperations)..where((o) => o.id.equals(id))).go();
  }

  /// Update retry count for failed operation
  Future<void> incrementSyncRetry(int id) async {
    final current = await (select(pendingSyncOperations)
          ..where((o) => o.id.equals(id)))
        .getSingleOrNull();
    
    if (current != null) {
      await (update(pendingSyncOperations)..where((o) => o.id.equals(id)))
          .write(
        PendingSyncOperationsCompanion(
          retryCount: Value(current.retryCount + 1),
          lastAttempt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════

  /// Delete old cached series (not downloaded, older than duration)
  Future<int> deleteOldCache(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    
    return await (delete(series)
          ..where((s) =>
              s.isDownloaded.equals(false) & s.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(series).go();
      await delete(chapters).go();
      await delete(volumes).go();
      await delete(downloadedPages).go();
      await delete(pendingSyncOperations).go();
    });
  }
}

// Database connection setup
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (SafePlatform.isWeb) {
      // Web: use IndexedDB
      return NativeDatabase.memory(); // TODO: Replace with web-compatible storage
    }

    // Mobile/Desktop: use SQLite file
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fluvita.db'));
    return NativeDatabase(file);
  });
}
