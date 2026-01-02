import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/pages/home/collapsible_section.dart';
import 'package:laya/riverpod/api/series.dart';
import 'package:laya/utils/layout_constants.dart';

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
