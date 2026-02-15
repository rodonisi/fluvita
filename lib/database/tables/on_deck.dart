import 'package:drift/drift.dart';

class OnDeck extends Table {
  IntColumn get seriesId => integer()();

  @override
  Set<Column> get primaryKey => {seriesId};
}
