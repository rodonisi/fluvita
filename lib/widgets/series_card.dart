import 'package:flutter/material.dart';
import 'package:fluvita/models/series_model.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/riverpod/router.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesCard extends ConsumerWidget {
  const SeriesCard({
    super.key,
    required this.series,
  });

  final SeriesModel series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = seriesProvider(seriesId: this.series.id);
    final series = ref.watch(provider).value ?? this.series;

    final markReadProvider = markSeriesReadProvider(seriesId: series.id);

    return ActionsContextMenu(
      onMarkRead: () async {
        await ref.read(markReadProvider.notifier).markRead();
        ref.invalidate(provider);
      },
      onMarkUnread: () async {
        await ref.read(markReadProvider.notifier).markUnread();
        ref.invalidate(provider);
      },
      child: CoverCard(
        title: series.name,
        icon: Icon(
          switch (series.format) {
            .epub => LucideIcons.bookText,
            .cbz => LucideIcons.fileArchive,
            .unknown => LucideIcons.fileQuestionMark,
          },
          size: LayoutConstants.smallIcon,
        ),
        progress: series.pagesRead / series.pages,
        coverImage: SeriesCoverImage(seriesId: series.id),
        onTap: () {
          SeriesDetailRoute(
            libraryId: series.libraryId,
            seriesId: series.id,
          ).push(context);
        },
        onRead: () {
          ReaderRoute(
            seriesId: series.id,
          ).push(context);
        },
      ),
    );
  }
}
