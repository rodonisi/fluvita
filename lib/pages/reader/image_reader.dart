import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluvita/pages/reader/reader_overlay.dart';
import 'package:fluvita/riverpod/reader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/api/reader.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';
import 'package:fluvita/widgets/async_value.dart';

class ImageReader extends HookConsumerWidget {
  final int seriesId;
  final int chapterId;

  const ImageReader({
    super.key,
    required this.seriesId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);
    final provider = readerProvider(seriesId: seriesId, chapterId: chapterId);

    final state = ref.watch(provider).value;
    if (state == null) {
      return Center(
        child: Text('Failed to load reader state.'),
      );
    }

    final pageController = usePageController(initialPage: state.currentPage);

    return ReaderOverlay(
      seriesId: seriesId,
      chapterId: chapterId,
      onNextPage: () {
        settings.readDirection == .leftToRight
            ? pageController.previousPage(
                duration: 100.ms,
                curve: Curves.easeInOut,
              )
            : pageController.nextPage(
                duration: 100.ms,
                curve: Curves.easeInOut,
              );
      },
      onPreviousPage: () {
        settings.readDirection == .leftToRight
            ? pageController.nextPage(duration: 100.ms, curve: Curves.easeInOut)
            : pageController.previousPage(
                duration: 100.ms,
                curve: Curves.easeInOut,
              );
      },
      onJumpToPage: (page) {
        pageController.jumpToPage(page);
      },
      child: PageView.builder(
        controller: pageController,
        allowImplicitScrolling: true,
        reverse:
            settings.readerMode == .horizontal &&
            settings.readDirection == .leftToRight,
        scrollDirection: settings.readerMode == .vertical
            ? .vertical
            : .horizontal,
        itemCount: state.totalPages,
        pageSnapping: settings.readerMode == .horizontal,
        onPageChanged: (index) {
          ref.read(provider.notifier).gotoPage(index);
        },
        itemBuilder: (context, index) {
          return Async(
            asyncValue: ref.watch(
              readerImageProvider(chapterId: chapterId, page: index),
            ),
            data: (data) {
              return Image.memory(
                data,
                fit: settings.scaleType == .fitWidth ? .fitWidth : .fitHeight,
              );
            },
          );
        },
      ),
    );
  }
}
