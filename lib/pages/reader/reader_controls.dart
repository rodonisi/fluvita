import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/pages/reader/epub_reader_controls.dart';
import 'package:fluvita/pages/reader/image_reader_controls.dart';
import 'package:fluvita/pages/reader/page_slider.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:fluvita/utils/layout_constants.dart';

class ReaderControls extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;
  const ReaderControls({super.key, required this.seriesId, this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final format = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId).select(
        (state) => state.value?.series.format,
      ),
    );
    return Card(
      margin: LayoutConstants.mediumEdgeInsets,
      child: Padding(
        padding: LayoutConstants.smallEdgeInsets,
        child: Column(
          mainAxisSize: .min,
          children: [
            PageSlider(
              seriesId: seriesId,
              chapterId: chapterId,
            ),
            if (format == .epub) EpubReaderControls(),
            if (format == .cbz) ImageReaderControls(),
          ],
        ),
      ),
    );
  }
}
