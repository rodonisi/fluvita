# Offline Reading Architecture Proposal for Fluvita

## Current State Analysis

### Problems Identified

1. **Always-Fetch Architecture**: All API providers (`@JsonPersist`) make network calls even when data is cached
   - Example: `Series`, `Chapter`, `ReaderImage` providers ALWAYS call `client.apiXxx()`
   - Cache only hydrates initial state, then immediately fetches from network
   - No offline-first strategy - app breaks without network

2. **Incomplete Download System**: 
   - `DownloadManager` exists but only downloads chapter pages (epub/images)
   - Doesn't download metadata (series info, chapter lists, progress)
   - Downloaded content not integrated with main data flow

3. **No Network Awareness**:
   - No connectivity detection
   - No fallback to cached data when offline
   - No queue for sync operations (mark as read, progress updates)

4. **TTL-Based Cache Invalidation**:
   - Current `StorageEntry.expireAt` forces re-fetches
   - No manual control over cache freshness
   - Cache treated as temporary, not source of truth

---

## Proposed Architecture: Repository Pattern with Offline-First Strategy

### Core Principles

1. **Single Source of Truth**: Local database is the primary data source
2. **Network as Background Sync**: API updates local DB, UI reads from DB
3. **Graceful Degradation**: App fully functional offline with cached data
4. **Smart Syncing**: Queue mutations offline, sync when connected

---

## Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│ UI Layer (Pages/Widgets)                            │
│ - Riverpod Providers (watch repositories)           │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│ Repository Layer (NEW)                               │
│ - SeriesRepository, ChapterRepository, etc.         │
│ - Orchestrates local + remote data sources          │
│ - Implements offline-first logic                    │
└────────────┬────────────────────────┬────────────────┘
             │                        │
             ▼                        ▼
┌────────────────────────┐  ┌────────────────────────┐
│ Local Data Source      │  │ Remote Data Source     │
│ - Hive/Isar/Drift      │  │ - Chopper API Client   │
│ - Reactive queries     │  │ - Network calls        │
│ - Offline storage      │  │ - DTO mapping          │
└────────────────────────┘  └────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────┐
│ Sync Engine (NEW)                                    │
│ - Network state monitoring                          │
│ - Background sync queue                             │
│ - Conflict resolution                               │
└─────────────────────────────────────────────────────┘
```

---

## Implementation Details

### 1. Local Database Layer

**Recommendation: Drift (SQLite)**
- **Why**: Reactive streams, type-safe queries, good Flutter support, better relations than Hive
- **Alternative**: Isar (if performance is critical, but less mature)

```dart
// lib/database/app_database.dart
@DriftDatabase(tables: [
  SeriesTable,
  ChaptersTable,
  VolumesTable,
  ProgressTable,
  LibrariesTable,
  DownloadedPagesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Reactive query: watch series (auto-updates UI)
  Stream<SeriesData> watchSeries(int seriesId) {
    return (select(seriesTable)..where((t) => t.id.equals(seriesId)))
        .watchSingle();
  }

  // Batch upsert from API
  Future<void> upsertSeries(List<SeriesModel> series) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(seriesTable, series);
    });
  }
}

// Example table
class SeriesTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get format => text()();
  IntColumn get libraryId => integer()();
  TextColumn get colors => text().nullable()();
  DateTimeColumn get lastModified => dateTime()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### 2. Repository Layer Pattern

**Example: SeriesRepository**

```dart
// lib/repositories/series_repository.dart
@riverpod
class SeriesRepository extends _$SeriesRepository {
  @override
  FutureOr<void> build() {}

  AppDatabase get _db => ref.read(databaseProvider);
  Openapi get _api => ref.read(restClientProvider);

  // ──────────────────────────────────────────────────
  // QUERIES (offline-first)
  // ──────────────────────────────────────────────────

  /// Watch series (reactive stream from local DB)
  Stream<SeriesModel> watchSeries(int seriesId) {
    return _db.watchSeries(seriesId).map(SeriesModel.fromDrift);
  }

  /// Get series (returns cached, triggers background refresh)
  Future<SeriesModel> getSeries(int seriesId) async {
    // 1. Return local data immediately
    final local = await _db.getSeries(seriesId);
    if (local != null) {
      // 2. Background refresh if stale (optional)
      _refreshSeries(seriesId); // fire-and-forget
      return SeriesModel.fromDrift(local);
    }

    // 3. If no cache, force fetch
    return await _fetchAndCacheSeries(seriesId);
  }

  /// Get all series for library (offline-first)
  Stream<List<SeriesModel>> watchAllSeries({int? libraryId}) {
    return _db.watchAllSeries(libraryId: libraryId)
        .map((list) => list.map(SeriesModel.fromDrift).toList());
  }

  // ──────────────────────────────────────────────────
  // MUTATIONS (queue offline, sync when connected)
  // ──────────────────────────────────────────────────

  Future<void> refreshSeries(int seriesId) async {
    if (ref.read(networkStatusProvider) == .offline) {
      log.i('Offline: skipping refresh for series $seriesId');
      return; // Gracefully skip when offline
    }
    await _fetchAndCacheSeries(seriesId);
  }

  // ──────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────────

  Future<SeriesModel> _fetchAndCacheSeries(int seriesId) async {
    final res = await _api.apiSeriesSeriesIdGet(seriesId: seriesId);
    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to fetch series: ${res.error}');
    }

    final model = SeriesModel.fromSeriesDto(res.body!);
    await _db.upsertSeries([model]); // Cache to local DB
    return model;
  }

  Future<void> _refreshSeries(int seriesId) async {
    try {
      await _fetchAndCacheSeries(seriesId);
    } catch (e) {
      log.w('Background refresh failed for series $seriesId: $e');
      // Fail silently - user already has cached data
    }
  }
}
```

### 3. Network Awareness

```dart
// lib/services/network_status.dart
enum NetworkStatus { online, offline }

@riverpod
class NetworkStatusNotifier extends _$NetworkStatusNotifier {
  @override
  NetworkStatus build() {
    _listen();
    return NetworkStatus.online; // Assume online initially
  }

  void _listen() {
    Connectivity().onConnectivityChanged.listen((result) {
      state = result == ConnectivityResult.none 
          ? NetworkStatus.offline 
          : NetworkStatus.online;
      
      if (state == .online) {
        ref.read(syncEngineProvider.notifier).syncPendingOperations();
      }
    });
  }
}
```

### 4. Sync Engine for Mutations

```dart
// lib/services/sync_engine.dart
@freezed
sealed class PendingOperation with _$PendingOperation {
  const factory PendingOperation.markRead({
    required int seriesId,
    int? chapterId,
    int? volumeId,
  }) = MarkReadOperation;

  const factory PendingOperation.updateProgress({
    required int chapterId,
    required int page,
  }) = UpdateProgressOperation;
  
  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);
}

@riverpod
@JsonPersist()
class SyncEngine extends _$SyncEngine {
  @override
  Future<List<PendingOperation>> build() async {
    persist(ref.watch(storageProvider.future));
    return state.value ?? [];
  }

  /// Queue operation to execute when online
  Future<void> enqueue(PendingOperation op) async {
    final current = state.value ?? [];
    state = AsyncData([...current, op]);

    // Try immediate sync if online
    if (ref.read(networkStatusProvider) == .online) {
      await syncPendingOperations();
    }
  }

  /// Execute all pending operations
  Future<void> syncPendingOperations() async {
    final pending = state.value ?? [];
    if (pending.isEmpty) return;

    final client = ref.read(restClientProvider);
    final successful = <PendingOperation>[];

    for (final op in pending) {
      try {
        await op.when(
          markRead: (seriesId, chapterId, volumeId) async {
            if (chapterId != null) {
              await client.apiReaderMarkMultipleReadPost(
                body: MarkVolumesReadDto(seriesId: seriesId, chapterIds: [chapterId]),
              );
            }
            // ... handle other mark read variations
          },
          updateProgress: (chapterId, page) async {
            await client.apiReaderProgressPost(
              body: ProgressUpdateDto(chapterId: chapterId, pageNum: page),
            );
          },
        );
        successful.add(op);
      } catch (e) {
        log.e('Failed to sync operation $op: $e');
        // Keep in queue for retry
      }
    }

    // Remove successful operations
    final remaining = pending.where((op) => !successful.contains(op)).toList();
    state = AsyncData(remaining);
  }
}
```

### 5. Download Manager Enhancement

```dart
// lib/repositories/download_repository.dart
@riverpod
class DownloadRepository extends _$DownloadRepository {
  @override
  FutureOr<void> build() {}

  /// Download entire chapter for offline reading
  Future<void> downloadChapter(int chapterId) async {
    // 1. Download metadata
    final chapter = await ref.read(
      chapterRepositoryProvider.notifier
    ).fetchChapter(chapterId);
    
    final bookInfo = await ref.read(
      bookRepositoryProvider.notifier
    ).fetchBookInfo(chapterId);

    // 2. Download all pages
    final downloadManager = ref.read(
      downloadManagerProvider(chapterId: chapterId).notifier
    );
    await downloadManager.download(); // Existing logic

    // 3. Mark as downloaded in DB
    await ref.read(databaseProvider).markChapterDownloaded(
      chapterId,
      isDownloaded: true,
    );

    log.i('Chapter $chapterId fully downloaded for offline use');
  }

  /// Download entire series
  Future<void> downloadSeries(int seriesId) async {
    final seriesDetail = await ref.read(
      seriesRepositoryProvider.notifier
    ).fetchSeriesDetail(seriesId);

    for (final volume in seriesDetail.volumes) {
      for (final chapter in volume.chapters) {
        await downloadChapter(chapter.id);
      }
    }

    await ref.read(databaseProvider).markSeriesDownloaded(
      seriesId,
      isDownloaded: true,
    );
  }

  /// Check if chapter is available offline
  Future<bool> isChapterDownloaded(int chapterId) async {
    final chapter = await ref.read(databaseProvider).getChapter(chapterId);
    return chapter?.isDownloaded ?? false;
  }
}
```

---

## Migration Strategy

### Phase 1: Foundation (Week 1-2)
- [ ] Set up Drift database schema
- [ ] Create migration from Hive cache to Drift
- [ ] Implement network status monitoring
- [ ] Create base repository pattern for one entity (Series)

### Phase 2: Repository Layer (Week 2-3)
- [ ] Implement all repositories (Series, Chapter, Volume, Library, etc.)
- [ ] Convert existing providers to use repositories
- [ ] Add offline-first queries with background refresh

### Phase 3: Sync Engine (Week 3-4)
- [ ] Build pending operations queue
- [ ] Implement sync logic for mutations (mark as read, progress)
- [ ] Add conflict resolution
- [ ] Test offline → online transitions

### Phase 4: Enhanced Downloads (Week 4-5)
- [ ] Extend DownloadManager to save to Drift
- [ ] Implement batch download for series/volumes
- [ ] Add download progress UI
- [ ] Storage management (delete downloads, cache limits)

### Phase 5: Testing & Polish (Week 5-6)
- [ ] Integration tests for offline scenarios
- [ ] Performance testing (large libraries)
- [ ] UI indicators (offline mode, sync status)
- [ ] Documentation

---

## API Changes Required

### Current Provider Pattern (Remove)
```dart
@riverpod
@JsonPersist()
class Series extends _$Series {
  @override
  Future<SeriesModel> build({required int seriesId}) async {
    persist(ref.watch(storageProvider.future));
    final client = ref.watch(restClientProvider);
    final res = await client.apiSeriesSeriesIdGet(seriesId: seriesId);
    return SeriesModel.fromSeriesDto(res.body!);
  }
}
```

### New Repository Pattern (Add)
```dart
@riverpod
Stream<SeriesModel> series({required int seriesId}) {
  final repo = ref.watch(seriesRepositoryProvider.notifier);
  return repo.watchSeries(seriesId); // Reactive stream from DB
}

@riverpod
Future<void> refreshSeries({required int seriesId}) async {
  final repo = ref.read(seriesRepositoryProvider.notifier);
  await repo.refreshSeries(seriesId); // Manual refresh
}
```

### UI Widget Changes (Minimal)
```dart
// Before
final series = ref.watch(seriesProvider(seriesId: id));

// After (almost identical!)
final series = ref.watch(seriesProvider(seriesId: id));
// Now backed by Stream<SeriesModel> instead of Future<SeriesModel>
```

---

## Benefits of This Architecture

### ✅ Offline-First
- App works fully offline with cached data
- No blank screens or loading spinners when offline
- Graceful degradation

### ✅ Better UX
- Instant data loads (from local DB)
- Background refresh doesn't block UI
- Optimistic updates for mutations

### ✅ Network Efficiency
- Reduce redundant API calls
- Smart caching strategy
- Batch sync operations

### ✅ Download Management
- True offline reading with all metadata
- Series/volume batch downloads
- Storage management

### ✅ Maintainability
- Clear separation of concerns (UI ← Repository ← Data Source)
- Testable business logic
- Type-safe database queries

---

## Alternatives Considered

### Alternative 1: Keep Riverpod @JsonPersist, Add Offline Check
**Pros**: Minimal changes
**Cons**: 
- Still makes network calls even when offline (just fails)
- No reactive updates from local DB
- Cache is temporary, not source of truth
- **Verdict**: ❌ Doesn't solve core problem

### Alternative 2: GraphQL + Apollo Client
**Pros**: Built-in caching, offline support
**Cons**: 
- Requires API rewrite (currently REST)
- Heavy dependency
- Overkill for this use case
- **Verdict**: ❌ Too invasive

### Alternative 3: Keep Hive, Add Repository Layer
**Pros**: Less migration work
**Cons**: 
- Hive not designed for relational data
- No reactive queries (need manual watchers)
- Complex queries difficult
- **Verdict**: ⚠️ Possible but not recommended

---

## Recommended Decision: Repository + Drift

**Rationale**:
- **Drift** provides reactive streams, relations, type safety
- **Repository pattern** is industry-standard for clean architecture
- **Minimal UI changes** (providers stay similar)
- **Future-proof** for offline-first mobile apps
- **Testable** (mock repositories easily)

---

## Open Questions

1. **Conflict Resolution**: What if user marks chapter as read offline, but server already marked it unread?
   - **Proposed**: Last-write-wins with timestamp comparison

2. **Cache Invalidation**: How long should data stay fresh?
   - **Proposed**: 
     - Metadata (series, chapters): 24 hours
     - Reading progress: Never (always show local)
     - Images: Indefinite (if downloaded)

3. **Storage Limits**: Should we limit local DB size?
   - **Proposed**: User-configurable limit (default 2GB), auto-delete oldest cached data

4. **Partial Downloads**: What if download fails midway?
   - **Proposed**: Mark chapter as partially downloaded, resume support

---

## Next Steps

If this architecture is approved:

1. Create proof-of-concept for Series entity
2. Benchmark Drift performance with large datasets
3. Design database schema in detail
4. Create migration plan from existing Hive cache
5. Start Phase 1 implementation

---

## References

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Repository Pattern in Flutter](https://codewithandrea.com/articles/flutter-repository-pattern/)
- [Offline-First Apps](https://developer.android.com/topic/architecture/data-layer/offline-first)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/reading)
