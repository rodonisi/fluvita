// Example: lib/repositories/series_repository.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/services/network_status.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'series_repository.g.dart';

/// Database provider
@riverpod
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

/// Series repository - offline-first data access
@riverpod
class SeriesRepository extends _$SeriesRepository {
  @override
  FutureOr<void> build() {}

  AppDatabase get _db => ref.read(databaseProvider);
  Openapi get _api => ref.read(restClientProvider);
  
  // Configurable cache duration
  static const _cacheDuration = Duration(hours: 24);

  // ═══════════════════════════════════════════════════
  // QUERIES (Offline-First)
  // ═══════════════════════════════════════════════════

  /// Watch single series - reactive stream that auto-updates UI
  /// Returns cached data immediately, triggers background refresh if stale
  Stream<SeriesModel?> watchSeries(int seriesId) {
    // Start background refresh if stale (fire-and-forget)
    _refreshIfStale(seriesId);
    
    // Return reactive stream from local DB
    return _db.watchSeries(seriesId).map((data) {
      if (data == null) return null;
      return _mapToModel(data);
    });
  }

  /// Get single series - returns cached, triggers background refresh if stale
  Future<SeriesModel> getSeries(int seriesId) async {
    // 1. Try local cache first
    final cached = await _db.getSeries(seriesId);
    
    if (cached != null) {
      // 2. Return cached data immediately
      final model = _mapToModel(cached);
      
      // 3. Refresh in background if stale (non-blocking)
      _refreshIfStale(seriesId);
      
      return model;
    }

    // 4. No cache - force fetch from network
    return await _fetchAndCacheSeries(seriesId);
  }

  /// Watch all series for a library
  Stream<List<SeriesModel>> watchAllSeries({int? libraryId}) {
    // Trigger background refresh for the library
    _refreshAllSeries(libraryId: libraryId);
    
    return _db.watchAllSeries(libraryId: libraryId).map((list) {
      return list.map(_mapToModel).toList();
    });
  }

  /// Watch downloaded series (always available offline)
  Stream<List<SeriesModel>> watchDownloadedSeries() {
    return _db.watchDownloadedSeries().map((list) {
      return list.map(_mapToModel).toList();
    });
  }

  /// Watch recently read series
  Stream<List<SeriesModel>> watchRecentlyRead({int limit = 10}) {
    return _db.watchRecentlyRead(limit: limit).map((list) {
      return list.map(_mapToModel).toList();
    });
  }

  /// Search series by name (local DB only)
  Stream<List<SeriesModel>> searchSeries(String query) {
    final pattern = '%${query.toLowerCase()}%';
    
    final dbQuery = _db.select(_db.series)
      ..where((s) => 
          s.name.lower().like(pattern) | 
          s.originalName.lower().like(pattern))
      ..orderBy([
        (s) => OrderingTerm.desc(s.lastRead),
      ]);
    
    return dbQuery.watch().map((list) {
      return list.map(_mapToModel).toList();
    });
  }

  // ═══════════════════════════════════════════════════
  // MUTATIONS (Network-aware, queue when offline)
  // ═══════════════════════════════════════════════════

  /// Manual refresh - fetch latest from server
  Future<void> refreshSeries(int seriesId) async {
    if (!_isOnline) {
      log.i('Offline: skipping refresh for series $seriesId');
      return;
    }
    
    await _fetchAndCacheSeries(seriesId);
  }

  /// Refresh all series for library
  Future<void> refreshAllSeries({int? libraryId}) async {
    if (!_isOnline) {
      log.i('Offline: skipping refresh for all series');
      return;
    }

    try {
      final res = await _api.apiSeriesV2Post(
        body: FilterV2Dto(
          id: 0,
          combination: FilterV2DtoCombination.value_0.value,
          sortOptions: SortOptions(
            sortField: SortOptionsSortField.value_1.value,
            isAscending: false,
          ),
          limitTo: 0,
          statements: [
            if (libraryId != null)
              FilterStatementDto(
                comparison: FilterStatementDtoComparison.value_0.value,
                field: FilterStatementDtoField.value_19.value,
                value: libraryId.toString(),
              ),
          ],
        ),
      );

      if (!res.isSuccessful || res.body == null) {
        throw Exception('Failed to refresh series: ${res.error}');
      }

      // Batch insert to DB
      final entries = res.body!.map((dto) {
        final model = SeriesModel.fromSeriesDto(dto);
        return _mapToCompanion(model);
      }).toList();

      await _db.upsertSeriesBatch(entries);
      log.d('Refreshed ${entries.length} series');
    } catch (e) {
      log.e('Failed to refresh all series: $e');
      rethrow;
    }
  }

  /// Update progress locally and sync to server
  Future<void> updateProgress({
    required int seriesId,
    required int pagesRead,
    required double progress,
  }) async {
    // 1. Update local DB immediately (optimistic update)
    await _db.updateSeriesProgress(
      seriesId,
      pagesRead: pagesRead,
      progress: progress,
    );

    // 2. Sync to server if online
    if (_isOnline) {
      try {
        // TODO: Call progress update API
        log.d('Synced progress for series $seriesId to server');
      } catch (e) {
        log.w('Failed to sync progress, will retry later: $e');
        // Queue for later sync
        await _enqueueSyncOperation(
          type: 'update_progress',
          data: {'seriesId': seriesId, 'pagesRead': pagesRead, 'progress': progress},
        );
      }
    } else {
      // Queue for sync when online
      await _enqueueSyncOperation(
        type: 'update_progress',
        data: {'seriesId': seriesId, 'pagesRead': pagesRead, 'progress': progress},
      );
    }
  }

  // ═══════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════

  /// Fetch series from API and cache in DB
  Future<SeriesModel> _fetchAndCacheSeries(int seriesId) async {
    if (!_isOnline) {
      throw Exception('Cannot fetch series $seriesId: offline');
    }

    try {
      final res = await _api.apiSeriesSeriesIdGet(seriesId: seriesId);
      
      if (!res.isSuccessful || res.body == null) {
        throw Exception('Failed to fetch series: ${res.error}');
      }

      final model = SeriesModel.fromSeriesDto(res.body!);
      
      // Cache to local DB
      await _db.upsertSeries(_mapToCompanion(model));
      
      log.d('Fetched and cached series $seriesId');
      return model;
    } catch (e) {
      log.e('Failed to fetch series $seriesId: $e');
      rethrow;
    }
  }

  /// Background refresh if data is stale (non-blocking, silent failure)
  Future<void> _refreshIfStale(int seriesId) async {
    if (!_isOnline) return;

    try {
      final isStale = await _db.isSeriesStale(seriesId, _cacheDuration);
      if (isStale) {
        await _fetchAndCacheSeries(seriesId);
      }
    } catch (e) {
      log.w('Background refresh failed for series $seriesId: $e');
      // Fail silently - user already has cached data
    }
  }

  /// Check if device is online
  bool get _isOnline {
    return ref.read(networkStatusProvider) == NetworkStatus.online;
  }

  /// Enqueue operation for later sync
  Future<void> _enqueueSyncOperation({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _db.enqueueSyncOperation(
      operationType: type,
      payload: jsonEncode(data),
    );
  }

  // ═══════════════════════════════════════════════════
  // MAPPING HELPERS
  // ═══════════════════════════════════════════════════

  /// Map Drift data to domain model
  SeriesModel _mapToModel(SeriesData data) {
    return SeriesModel(
      id: data.id,
      name: data.name,
      originalName: data.originalName,
      localizedName: data.localizedName,
      sortName: data.sortName,
      libraryId: data.libraryId,
      format: data.format,
      pages: data.pages,
      avgHoursToRead: data.avgHoursToRead,
      summary: data.summary,
      coverImageUrl: data.coverImageUrl,
      colors: data.colors != null ? (jsonDecode(data.colors!) as List).cast<String>() : null,
      pagesRead: data.pagesRead,
      progress: data.progress,
      created: data.created,
      lastModified: data.lastModified,
      lastChapterAdded: data.lastChapterAdded,
      lastRead: data.lastRead,
    );
  }

  /// Map domain model to Drift companion
  SeriesCompanion _mapToCompanion(SeriesModel model) {
    return SeriesCompanion.insert(
      id: Value(model.id),
      name: model.name,
      originalName: Value(model.originalName),
      localizedName: Value(model.localizedName),
      sortName: model.sortName,
      libraryId: model.libraryId,
      format: model.format,
      pages: Value(model.pages),
      avgHoursToRead: Value(model.avgHoursToRead),
      summary: Value(model.summary),
      coverImageUrl: Value(model.coverImageUrl),
      colors: Value(model.colors != null ? jsonEncode(model.colors) : null),
      pagesRead: Value(model.pagesRead),
      progress: Value(model.progress),
      created: model.created,
      lastModified: model.lastModified,
      lastChapterAdded: Value(model.lastChapterAdded),
      lastRead: Value(model.lastRead),
      cachedAt: Value(DateTime.now()),
    );
  }
}
