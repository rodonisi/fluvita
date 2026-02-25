import 'package:drift/drift.dart';
import 'package:fluvita/database/app_database.dart';
import 'package:fluvita/database/tables/series_metadata.dart';
import 'package:stream_transform/stream_transform.dart';

part 'series_metadata_dao.g.dart';

@DriftAccessor(
  tables: [
    SeriesMetadata,
    People,
    Genres,
    Tags,
    SeriesPeopleRoles,
    SeriesGenres,
    SeriesTags,
  ],
)
class SeriesMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SeriesMetadataDaoMixin {
  SeriesMetadataDao(super.attachedDatabase);

  /// Get series metadata for series [seriesId]
  Stream<SeriesMetadataWithRelations> watchSeriesMetadata(int seriesId) {
    return managers.seriesMetadata
        .withReferences(
          (prefetch) => prefetch(
            seriesGenresRefs: true,
            seriesPeopleRolesRefs: true,
            seriesTagsRefs: true,
          ),
        )
        .filter((f) => f.seriesId.id(seriesId))
        .asyncMap(
          (m) async {
            final (metadata, refs) = m;
            return SeriesMetadataWithRelations(
              metadata: metadata,
              writers: await Future.wait(
                refs.seriesPeopleRolesRefs.prefetchedData?.map(
                      (p) => managers.people
                          .filter((f) => f.id(p.personId))
                          .getSingle(),
                    ) ??
                    [],
              ),
              genres: await Future.wait(
                refs.seriesGenresRefs.prefetchedData?.map(
                      (g) => managers.genres
                          .filter(
                            (f) => f.id(g.genreId),
                          )
                          .getSingle(),
                    ) ??
                    [],
              ),
              tags: await Future.wait(
                refs.seriesTagsRefs.prefetchedData?.map(
                      (t) => managers.tags
                          .filter((f) => f.id(t.tagId))
                          .getSingle(),
                    ) ??
                    [],
              ),
            );
          },
        )
        .watchSingleOrNull()
        .whereNotNull();
  }

  /// Upsert batch of [SeriesMetadataCompanions]
  Future<void> upsertMetadataBatch(
    Iterable<SeriesMetadataCompanions> metadata,
  ) async {
    final items = metadata.toList();
    final meta = items.map((m) => m.metadata);
    final ws = items.map((m) => m.writers).expand((e) => e);
    final gs = items.map((m) => m.genres).expand((e) => e);
    final ts = items.map((m) => m.tags).expand((e) => e);
    final prs = items.map((m) => m.peopleRoles).expand((e) => e);
    final sgs = items.map((m) => m.seriesGenres).expand((e) => e);
    final sts = items.map((m) => m.seriesTags).expand((e) => e);

    await batch((batch) {
      batch.insertAllOnConflictUpdate(seriesMetadata, meta);
      batch.insertAllOnConflictUpdate(people, ws);
      batch.insertAllOnConflictUpdate(genres, gs);
      batch.insertAllOnConflictUpdate(tags, ts);
      batch.insertAllOnConflictUpdate(seriesPeopleRoles, prs);
      batch.insertAllOnConflictUpdate(seriesGenres, sgs);
      batch.insertAllOnConflictUpdate(seriesTags, sts);
    });
  }
}

class SeriesMetadataWithRelations {
  final SeriesMetadataData? metadata;
  final List<PeopleData> writers;
  final List<Genre> genres;
  final List<Tag> tags;

  SeriesMetadataWithRelations({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
  });
}

class SeriesMetadataCompanions {
  final SeriesMetadataCompanion metadata;
  final Iterable<PeopleCompanion> writers;
  final Iterable<GenresCompanion> genres;
  final Iterable<TagsCompanion> tags;
  final Iterable<SeriesPeopleRolesCompanion> peopleRoles;
  final Iterable<SeriesGenresCompanion> seriesGenres;
  final Iterable<SeriesTagsCompanion> seriesTags;

  SeriesMetadataCompanions({
    required this.metadata,
    required this.writers,
    required this.genres,
    required this.tags,
    required this.peopleRoles,
    required this.seriesGenres,
    required this.seriesTags,
  });
}
