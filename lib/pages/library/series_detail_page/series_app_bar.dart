import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/pages/library/series_detail_page/series_info.dart';
import 'package:fluvita/riverpod/api/series.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/measured_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final topPadding = MediaQuery.of(context).padding.top;

    final series = ref.watch(seriesProvider(seriesId: seriesId));

    final isCollapsed = useState(false);
    final infoHeight = useState(500.0);

    final collapsedHeight = useMemoized(
      () => kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      [kToolbarHeight, topPadding, bottom],
    );

    final expandedHeight = useMemoized(
      () => infoHeight.value + collapsedHeight,
      [infoHeight.value, collapsedHeight],
    );

    final maxFlexibleSpaceHeight = MediaQuery.of(context).size.height * 0.7;

    return AsyncSliver(
      asyncValue: series,
      data: (data) {
        return SliverAppBar(
          title: isCollapsed.value
              ? Text(
                  data.name,
                ).animate(target: isCollapsed.value ? 1 : 0).fade()
              : null,
          pinned: true,
          expandedHeight: expandedHeight,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final value =
                  (constraints.maxHeight - kToolbarHeight) / infoHeight.value;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                isCollapsed.value = constraints.maxHeight <= collapsedHeight;
              });

              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: FlexibleSpaceBar(
                  background: SeriesInfoFlexibleSpace(
                    seriesId: data.id,
                    child: SafeArea(
                      child: MeasuredWidget(
                        onSizeMeasured: (size) {
                          log.d('Measured SeriesInfo size: $size');
                          infoHeight.value = size.height;
                        },
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxFlexibleSpaceHeight,
                          ),
                          child: SeriesInfo(seriesId: data.id),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          bottom: bottom,
        );
      },
    );
  }
}
