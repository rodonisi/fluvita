// Example: lib/database/tables.dart
import 'package:drift/drift.dart';

/// Series table - stores all series metadata locally
class Series extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get originalName => text().nullable()();
  TextColumn get localizedName => text().nullable()();
  TextColumn get sortName => text()();
  IntColumn get libraryId => integer()();
  
  // Format: Book, Comic, Manga, etc.
  TextColumn get format => text()();
  
  // Metadata
  IntColumn get pages => integer().withDefault(const Constant(0))();
  RealColumn get avgHoursToRead => real().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  
  // Theme colors (JSON array)
  TextColumn get colors => text().nullable()();
  
  // Reading progress
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  
  // Timestamps
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastModified => dateTime()();
  DateTimeColumn get lastChapterAdded => dateTime().nullable()();
  DateTimeColumn get lastRead => dateTime().nullable()();
  
  // Offline support
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {name, libraryId}, // Series name unique per library
  ];
}

/// Chapters table - stores chapter metadata
class Chapters extends Table {
  IntColumn get id => integer()();
  IntColumn get seriesId => integer()();
  IntColumn get volumeId => integer().nullable()();
  
  TextColumn get title => text()();
  TextColumn get number => text()(); // Can be "1.5", "Special", etc.
  RealColumn get minNumber => real()();
  RealColumn get maxNumber => real()();
  IntColumn get volumeNumber => integer().withDefault(const Constant(0))();
  
  IntColumn get pages => integer().withDefault(const Constant(0))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  
  // Reading progress
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  
  // Timestamps
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get releaseDate => dateTime()();
  DateTimeColumn get lastRead => dateTime().nullable()();
  
  // Offline support
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// Volumes table - groups chapters
class Volumes extends Table {
  IntColumn get id => integer()();
  IntColumn get seriesId => integer()();
  IntColumn get number => integer()();
  
  TextColumn get name => text()();
  IntColumn get pages => integer().withDefault(const Constant(0))();
  IntColumn get chaptersCount => integer().withDefault(const Constant(0))();
  
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get created => dateTime()();
  DateTimeColumn get lastModified => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

/// Downloaded pages - stores actual page data/URLs
class DownloadedPages extends Table {
  IntColumn get chapterId => integer()();
  IntColumn get pageNumber => integer()();
  
  // Store either local file path or cached image data
  TextColumn get localPath => text().nullable()();
  BlobColumn get imageData => blob().nullable()();
  TextColumn get originalUrl => text()();
  
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {chapterId, pageNumber};
}

/// Pending sync operations - queue for offline mutations
class PendingSyncOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get operationType => text()(); // 'mark_read', 'progress_update', etc.
  TextColumn get payload => text()(); // JSON data
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
