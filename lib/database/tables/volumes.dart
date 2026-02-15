import 'package:drift/drift.dart';

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
