import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/api/image.dart';
import 'package:laya/widgets/async_value.dart';

class CoverImage extends ConsumerWidget {
  final int seriesId;
  const CoverImage({super.key, required this.seriesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(coverImageProvider(seriesId: seriesId)),
      data: (imageData) => ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.memory(
          imageData,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }
}
