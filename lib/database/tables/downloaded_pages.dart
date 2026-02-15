import 'package:drift/drift.dart';

class DownloadedPages extends Table {
  IntColumn get chapterId => integer()();
  IntColumn get pageNumber => integer()();

  // Store either local file path or cached image data
  TextColumn get page => text().nullable()();
  BlobColumn get imageData => blob().nullable()();
  TextColumn get originalUrl => text()();

  DateTimeColumn get downloadedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chapterId, pageNumber};
}
