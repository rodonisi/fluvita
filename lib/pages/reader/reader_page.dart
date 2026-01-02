import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:laya/pages/reader/epub_reader.dart';
import 'package:laya/pages/reader/image_reader.dart';
import 'package:laya/riverpod/reader.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReaderPage extends HookConsumerWidget {
  final int seriesId;
  final int? chapterId;

  const ReaderPage({super.key, required this.seriesId, this.chapterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiVisible = useState(false);

    final book = ref.watch(
      readerProvider(seriesId: seriesId, chapterId: chapterId),
    );

    return Async(
      asyncValue: book,
      data: (book) => Scaffold(
        appBar: uiVisible.value
            ? AppBar(
                title: Text(book.title),
              )
            : null,
        body: GestureDetector(
          onPanEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx < 0) {
              ref.read(readerProvider(seriesId: seriesId).notifier).nextPage();
            }
            if (details.velocity.pixelsPerSecond.dx > 0) {
              ref
                  .read(readerProvider(seriesId: seriesId).notifier)
                  .previousPage();
            }
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: switch (book.series.format) {
                  .epub => EpubReader(
                    chapterId: book.chapterId,
                    page: book.currentPage,
                  ),
                  .cbz => ImageReader(
                    chapterId: book.chapterId,
                    page: book.currentPage,
                  ),
                  .unknown => const Center(
                    child: Text('Unsupported format'),
                  ),
                },
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => ref
                            .read(readerProvider(seriesId: seriesId).notifier)
                            .previousPage(),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => uiVisible.value = !uiVisible.value,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => ref
                            .read(readerProvider(seriesId: seriesId).notifier)
                            .nextPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
