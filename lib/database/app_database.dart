import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fluvita/database/dao/series_dao.dart';
import 'package:fluvita/database/dao/storage_dao.dart';
import 'package:fluvita/database/tables/chapters.dart';
import 'package:fluvita/database/tables/riverpod_storage.dart';
import 'package:fluvita/database/tables/series.dart';
import 'package:fluvita/database/tables/downloaded_pages.dart';
import 'package:fluvita/database/tables/volumes.dart';
import 'package:fluvita/database/tables/pending_sync_operations.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/utils/safe_platform.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Series, RiverpodStorage],
  daos: [SeriesDao, StorageDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(series).go();
    });
  }

  static QueryExecutor _openConnection() {
    if (SafePlatform.isWeb) {
      return NativeDatabase.memory();
    }
    return driftDatabase(
      name: 'fluvita_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
