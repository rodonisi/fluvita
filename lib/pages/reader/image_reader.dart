import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/reader.dart';
import 'package:laya/widgets/async_value.dart';

class ImageReader extends ConsumerWidget {
  final int chapterId;
  final int page;

  const ImageReader({
    super.key,
    required this.chapterId,
    required this.page,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(
        readerImageProvider(chapterId: chapterId, page: page),
      ),
      data: (data) => Image.memory(data),
    );
  }
}
