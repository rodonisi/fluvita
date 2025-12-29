import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:laya/riverpod/api.dart';
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
                  child: Html(
                    data: book.currentPageContent,
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
