import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/volume_model.dart';
import 'package:kover/pages/library/menu_page/app_list_tile.dart';
import 'package:kover/pages/library/series_detail_page/chapters_page.dart';
import 'package:kover/pages/library/series_detail_page/series_app_bar.dart';
import 'package:kover/pages/library/series_detail_page/series_detail_page.dart';
import 'package:kover/pages/library/volume_detail_page/volume_app_bar.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/volume.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/chapter_grid.dart';
import 'package:kover/widgets/sliver_bottom_padding.dart';

class VolumeDetailPage extends HookConsumerWidget {
  final int volumeId;

  const VolumeDetailPage({
    super.key,
    required this.volumeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider(volumeId: volumeId)).value;
    final progress = ref
        .watch(volumeProgressProvider(volumeId: volumeId))
        .value;

    if (volume == null) return SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          VolumeAppBar(
            volume: volume,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: progress,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              top: LayoutConstants.mediumPadding,
              right: LayoutConstants.mediumPadding,
              left: LayoutConstants.mediumPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Summary(
                    summary: volume.chapters.first.summary,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: LayoutConstants.mediumPadding,
              vertical: LayoutConstants.smallPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Chapters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutConstants.mediumPadding,
            ),
            sliver: ChaptersGrid(
              seriesId: volume.seriesId,
              chapters: volume.chapters,
            ),
          ),

          SliverBottomPadding(),
        ],
      ),
    );
  }
}
