import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:laya/riverpod/book.dart';
import 'package:laya/widgets/async_value.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ReaderPage extends HookConsumerWidget {
  final int seriesId;

  const ReaderPage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiVisible = useState(false);

    final book = ref.watch(bookProvider(seriesId: seriesId));

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
              ref.read(bookProvider(seriesId: seriesId).notifier).nextPage();
            }
            if (details.velocity.pixelsPerSecond.dx > 0) {
              ref
                  .read(bookProvider(seriesId: seriesId).notifier)
                  .previousPage();
            }
          },

          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final styles =
                          """
                      <head>
                      <style>
.kavita-scale-width-container {
  width: auto;
  max-height: ${constraints.maxHeight} !important;
  max-width: ${constraints.maxWidth} !important;
  position: var(--book-reader-content-position) !important;
  top: var(--book-reader-content-top) !important;
  left: var(--book-reader-content-left) !important;
  transform: var(--book-reader-content-transform) !important;
}

// This is applied to images in the backend
.kavita-scale-width {
  max-height: ${constraints.maxHeight} !important;
  max-width: ${constraints.maxWidth} !important;
  object-fit: contain;
  object-position: top center;
  break-inside: avoid;
  break-before: column;
  max-height: 100vh;
}
                      </style>
                      </head>
""";
                      return HtmlWidget(
                        styles + book.currentPageContent,
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => ref
                            .read(bookProvider(seriesId: seriesId).notifier)
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
                            .read(bookProvider(seriesId: seriesId).notifier)
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
