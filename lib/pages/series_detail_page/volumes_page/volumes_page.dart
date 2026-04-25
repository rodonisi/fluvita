import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/cards/volume_card.dart';
import 'package:kover/widgets/details/filter_input_field.dart';
import 'package:kover/widgets/lists/adaptive_sliver_grid.dart';
import 'package:kover/widgets/sliver_bottom_padding.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VolumesPage extends HookConsumerWidget {
  final int seriesId;
  const VolumesPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hideRead = useState(false);
    final controller = useTextEditingController();
    useListenable(controller);

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Volumes'),
              actions: [
                IconButton(
                  onPressed: () => hideRead.value = !hideRead.value,
                  tooltip: hideRead.value ? 'Show read' : 'Hide read',
                  icon: Icon(
                    hideRead.value ? LucideIcons.eyeOff : LucideIcons.eye,
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: LayoutConstants.mediumPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: FilterInputField(controller: controller),
              ),
            ),
            SliverPadding(
              padding: LayoutConstants.smallEdgeInsets,
              sliver: _VolumeGrid(
                seriesId: seriesId,
                hideRead: hideRead.value,
                filter: controller.text,
              ),
            ),
            const SliverBottomPadding(),
          ],
        ),
      ),
    );
  }
}

class _VolumeGrid extends HookConsumerWidget {
  final int seriesId;
  final bool hideRead;
  final String? filter;

  const _VolumeGrid({
    required this.seriesId,
    this.hideRead = false,
    this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volumes = ref.watch(
      seriesDetailProvider(
        seriesId: seriesId,
      ).select(
        (state) =>
            (hideRead ? state.value?.unreadVolumes : state.value?.volumes) ??
            [],
      ),
    );

    final filteredVolumes = (filter == null || filter!.isEmpty)
        ? volumes
        : volumes
              .where(
                (v) => v.name.toLowerCase().contains(filter!.toLowerCase()),
              )
              .toList();

    return AdaptiveSliverGrid(
      itemCount: filteredVolumes.length,
      builder: (context, index) {
        final volume = filteredVolumes[index];
        return VolumeCard(volumeId: volume.id);
      },
    );
  }
}
