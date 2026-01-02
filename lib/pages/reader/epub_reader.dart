import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/book.dart';
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/async_value.dart';

class EpubReader extends ConsumerWidget {
  final int chapterId;
  final int page;

  const EpubReader({
    super.key,
    required this.chapterId,
    required this.page,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(
        bookPageProvider(chapterId: chapterId, page: page),
      ),
      data: (data) => SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: LayoutConstants.largeEdgeInsets,
              child: HtmlWidget(data),
            );
          },
        ),
      ),
    );
  }
}
