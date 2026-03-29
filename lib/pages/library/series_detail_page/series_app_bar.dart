import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/pages/library/series_detail_page/series_info_background.dart';
import 'package:kover/riverpod/managers/download_manager.dart';
import 'package:kover/riverpod/providers/download.dart';
import 'package:kover/riverpod/providers/reader.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/actions_menu.dart';
import 'package:kover/widgets/adaptive_sliver_app_bar.dart';
import 'package:kover/widgets/async_value.dart';
import 'package:kover/widgets/cover_image.dart';
import 'package:kover/widgets/info_widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SeriesAppBar extends HookConsumerWidget {
  final int seriesId;
  final PreferredSizeWidget? bottom;

  const SeriesAppBar({
    super.key,
    required this.seriesId,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));
    final downloadProgress =
        ref.watch(seriesDownloadProgressProvider(seriesId: seriesId)).value ??
        0.0;
    final progress = ref.watch(seriesProgressProvider(seriesId: seriesId));

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return AdaptiveSliverAppBar(
          title: CoverAppBarTitle(
            cover: TitleContinueButton(seriesId: seriesId),
            title: Text(
              data.name,
              overflow: .fade,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(value: progress.value),
          ),
          actions: [
            WantToReadToggle(seriesId: data.id),
            ActionsMenuButton(
              onMarkRead: () async {
                await ref
                    .read(
                      markSeriesReadProvider(
                        seriesId: seriesId,
                      ).notifier,
                    )
                    .markRead();
                ref.invalidate(
                  seriesDetailProvider(seriesId: seriesId),
                );
              },
              onMarkUnread: () async {
                await ref
                    .read(
                      markSeriesReadProvider(
                        seriesId: seriesId,
                      ).notifier,
                    )
                    .markUnread();
                ref.invalidate(
                  seriesDetailProvider(seriesId: seriesId),
                );
              },
              onDownload: downloadProgress < 1.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .enqueueSeries(seriesId);
                    }
                  : null,
              onRemoveDownload: downloadProgress > 0.0
                  ? () async {
                      await ref
                          .read(downloadManagerProvider.notifier)
                          .deleteSeries(seriesId);
                    }
                  : null,
              child: const Icon(LucideIcons.ellipsisVertical),
            ),
          ],
          background: SeriesInfoBackground(
            primaryColor: data.primaryColor,
            secondaryColor: data.secondaryColor,
          ),
          child: _SeriesInfo(seriesId: seriesId),
        );
      },
    );
  }
}

class _SeriesInfo extends ConsumerWidget {
  final int seriesId;
  const _SeriesInfo({
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(seriesProvider(seriesId: seriesId));

    return Async(
      asyncValue: series,
      data: (series) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutConstants.largePadding,
        ),
        child: Column(
          spacing: LayoutConstants.largePadding,
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            const SizedBox.square(dimension: kToolbarHeight),
            Text(
              series.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              spacing: LayoutConstants.largePadding,
              children: [
                SizedBox(
                  height: 200,
                  child: _Cover(seriesId: series.id),
                ),
                Expanded(
                  child: _Metadata(
                    series: series,
                  ),
                ),
              ],
            ),
            ContinueButton(
              seriesId: seriesId,
            ),
            const SizedBox(
              height: LayoutConstants.smallPadding,
            ),
          ],
        ),
      ),
    );
  }
}

class ContinueButtonImage extends ConsumerWidget {
  final int seriesId;
  const ContinueButtonImage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final continuePoint = ref.watch(continuePointProvider(seriesId: seriesId));

    return Async(
      asyncValue: continuePoint,
      data: (data) => Stack(
        children: [
          Positioned.fill(
            child: SizedBox.square(
              dimension: LayoutConstants.largerIcon,
              child: ChapterCoverImage(chapterId: data.id),
            ),
          ),
          Align(
            alignment: .center,
            child: Icon(
              Icons.play_arrow_rounded,
              size: LayoutConstants.largeIcon,
              shadows: const [Shadow(blurRadius: 3)],
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleContinueButton extends ConsumerWidget {
  const TitleContinueButton({
    super.key,
    required this.seriesId,
  });

  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(child: ContinueButtonImage(seriesId: seriesId)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          ),
        ),
      ],
    );
  }
}

class ContinueButton extends ConsumerWidget {
  final int seriesId;

  const ContinueButton({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final continuePoint = ref.watch(continuePointProvider(seriesId: seriesId));
    final progress = ref.watch(
      continuePointProgressProvider(seriesId: seriesId),
    );

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.secondaryContainer,
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(
          LayoutConstants.mediumBorderRadius,
        ),
      ),
      child: Async(
        asyncValue: continuePoint,
        data: (data) => InkWell(
          onTap: () => ReaderRoute(seriesId: seriesId).push(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: LayoutConstants.mediumPadding,
              mainAxisAlignment: .center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(
                    LayoutConstants.smallBorderRadius,
                  ),
                  child: SizedBox.square(
                    dimension: LayoutConstants.largerIcon,
                    child: ContinueButtonImage(seriesId: seriesId),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      Text(
                        'Continue Reading',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        data.title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox.square(
                  dimension: LayoutConstants.largerIcon,
                  child: Padding(
                    padding: LayoutConstants.smallEdgeInsets,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                      strokeCap: .round,
                      backgroundColor: theme.colorScheme.onSecondaryFixed,
                      value: progress.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Metadata extends ConsumerWidget {
  final SeriesModel series;
  const _Metadata({
    required this.series,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadata = ref.watch(seriesMetadataProvider(seriesId: series.id));
    return Async(
      asyncValue: metadata,
      data: (metadata) => Column(
        crossAxisAlignment: .start,
        spacing: LayoutConstants.largePadding,
        children: [
          Wrap(
            spacing: LayoutConstants.mediumPadding,
            runSpacing: LayoutConstants.mediumPadding,
            alignment: .spaceBetween,
            children: [
              if ((series.wordCount ?? 0) > 0)
                WordCount(wordCount: series.wordCount!),
              Pages(pages: series.pages),
              RemainingHours(
                hours: series.avgHoursToRead,
              ),
              if (metadata.releaseYear != null)
                ReleaseYear(
                  releaseYear: metadata.releaseYear!,
                ),
            ],
          ),
          Wrap(
            spacing: LayoutConstants.mediumPadding,
            runSpacing: LayoutConstants.mediumPadding,
            alignment: .spaceBetween,
            children: [
              LimitedList(
                title: 'Writers',
                items: metadata.writers
                    .map(
                      (w) => Text(
                        w.name,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cover extends ConsumerWidget {
  final int seriesId;

  const _Cover({
    required this.seriesId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(
        LayoutConstants.smallBorderRadius,
      ),
      child: SeriesCoverImage(seriesId: seriesId),
    );
  }
}

class CoverAppBarTitle extends StatelessWidget {
  final Widget? cover;
  final Widget title;

  const CoverAppBarTitle({super.key, required this.title, this.cover});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: LayoutConstants.mediumPadding,
      children: [
        SizedBox.square(
          dimension: kToolbarHeight - LayoutConstants.mediumPadding,
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(
              LayoutConstants.smallPadding,
            ),
            child: cover,
          ),
        ),
        Flexible(child: title),
      ],
    );
  }
}
