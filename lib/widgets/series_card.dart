import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/providers/router.dart';
import 'package:fluvita/riverpod/providers/series.dart';
import 'package:fluvita/riverpod/providers/want_to_read.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesCard extends HookConsumerWidget {
  const SeriesCard({
    super.key,
    required this.seriesId,
  });

  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final progress = ref
        .watch(seriesProgressProvider(seriesId: seriesId))
        .value;

    final canRead = ref.watch(canReadSeriesProvider(seriesId)).value ?? false;

    final wantToRead = wantToReadProvider(seriesId: seriesId);
    final isWantToRead = ref.watch(wantToRead).value ?? false;

    final markReadProvider = markSeriesReadProvider(seriesId: seriesId);

    final downloadProgress = ref
        .watch(seriesDownloadProgressProvider(seriesId: seriesId))
        .value;

    final repo = ref.read(downloadRepositoryProvider);

    void Function()? onDownloadSeries;
    void Function()? onRemoveSeriesDownload;

    if (downloadProgress != null && downloadProgress >= 1.0) {
      onRemoveSeriesDownload = () => repo.deleteSeries(seriesId: seriesId);
    } else {
      onDownloadSeries = () => repo.downloadSeries(seriesId: seriesId);
    }

    return Async(
      asyncValue: series,
      data: (series) => ActionsContextMenu(
        onMarkRead: () async {
          await ref.read(markReadProvider.notifier).markRead();
        },
        onMarkUnread: () async {
          await ref.read(markReadProvider.notifier).markUnread();
        },
        onAddWantToRead: isWantToRead
            ? null
            : () async {
                await ref.read(wantToRead.notifier).add();
              },
        onRemoveWantToRead: isWantToRead
            ? () async {
                await ref.read(wantToRead.notifier).remove();
              }
            : null,
        onDownloadSeries: onDownloadSeries,
        onRemoveSeriesDownload: onRemoveSeriesDownload,
        child: CoverCard(
          title: series.name,
          icon: Icon(
            switch (series.format) {
              .epub => LucideIcons.bookText,
              .archive => LucideIcons.fileArchive,
              .unknown => LucideIcons.fileQuestionMark,
            },
            size: LayoutConstants.smallIcon,
          ),
          progress: progress,
          coverImage: SeriesCoverImage(seriesId: seriesId),
          downloadStatusIcon: DownloadStatusIcon(
            progress: downloadProgress,
          ),
          onTap: () {
            SeriesDetailRoute(
              libraryId: series.libraryId,
              seriesId: seriesId,
            ).push(context);
          },
          onRead: canRead
              ? () {
                  ReaderRoute(
                    seriesId: seriesId,
                  ).push(context);
                }
              : null,
        ),
      ),
    );
  }
}
