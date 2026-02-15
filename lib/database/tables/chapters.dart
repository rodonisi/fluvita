import 'package:drift/drift.dart';

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
