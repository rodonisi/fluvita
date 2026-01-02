import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/models/series_model.dart';
import 'package:laya/riverpod/api/image.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/async_value.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            OnDeck(),
            RecentlyUpdated(),
            RecentlyAdded(),
            // bottom padding for scrolling past the navigation bar
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    LayoutConstants.mediumPadding +
                    MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnDeck extends ConsumerWidget {
  const OnDeck({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onDeck = ref.watch(onDeckProvider);

    return CollapsibleSection(title: 'On Deck', series: onDeck);
  }
}

class RecentlyUpdated extends ConsumerWidget {
  const RecentlyUpdated({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(recentlyUpdatedProvider);

    return CollapsibleSection(title: 'Recently Updated', series: series);
  }
}

class RecentlyAdded extends ConsumerWidget {
  const RecentlyAdded({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(recentlyAddedProvider);

    return CollapsibleSection(title: 'Recently Added', series: series);
  }
}

class CollapsibleSection extends HookConsumerWidget {
  final String title;
  final AsyncValue<List<SeriesModel>> series;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.series,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = useState(false);

    final collapsedCount = 3;
    final total = series.value?.length ?? 0;
    final toShow = showAll.value ? total : collapsedCount;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: LayoutConstants.mediumEdgeInsets,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (total > collapsedCount)
                  TextButton(
                    onPressed: () {
                      showAll.value = !showAll.value;
                    },
                    child: Text(showAll.value ? 'Show Less' : 'Show All'),
                  ),
              ],
            ),
          ),
        ),
        series.when(
          data: (data) {
            return SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final series = data[index];
                  return Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CoverImage(seriesId: series.id),
                              ),
                              Align(
                                child: IconButton.filled(
                                  iconSize: 32,
                                  onPressed: () {},
                                  icon: FaIcon(FontAwesomeIcons.readme),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: .min,
                            children: [
                              Expanded(
                                child: Text(
                                  series.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: toShow,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }
}

class CoverImage extends ConsumerWidget {
  final int seriesId;
  const CoverImage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(coverImageProvider(seriesId: seriesId)),
      data: (imageData) => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }
}
