import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/image_reader_settings.dart';

class ImageReaderControls extends ConsumerWidget {
  const ImageReaderControls({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageReaderSettingsProvider);

    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        IconButton(
          icon: FaIcon(
            settings.readDirection == .leftToRight
                ? FontAwesomeIcons.anglesLeft
                : FontAwesomeIcons.anglesRight,
          ),
          tooltip: 'Read Direction',
          onPressed: () {
            ref
                .read(imageReaderSettingsProvider.notifier)
                .toggleReadDirection();
          },
        ),
        IconButton(
          icon: FaIcon(
            settings.readerMode == .vertical
                ? FontAwesomeIcons.upDown
                : FontAwesomeIcons.leftRight,
          ),
          tooltip: 'Reader Mode',
          onPressed: () {
            ref.read(imageReaderSettingsProvider.notifier).toggleReaderMode();
          },
        ),
        // In vertical mode: gap control, in horizontal mode: fit control
        if (settings.readerMode == .vertical)
          Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.minus, size: 16),
                tooltip: 'Decrease gap',
                onPressed: settings.verticalImageGap > 0
                    ? () {
                        ref.read(imageReaderSettingsProvider.notifier).setVerticalImageGap(
                              (settings.verticalImageGap - 4).clamp(0.0, 32.0),
                            );
                      }
                    : null,
              ),
              IconButton(
                icon: FaIcon(FontAwesomeIcons.plus, size: 16),
                tooltip: 'Increase gap',
                onPressed: settings.verticalImageGap < 32
                    ? () {
                        ref.read(imageReaderSettingsProvider.notifier).setVerticalImageGap(
                              (settings.verticalImageGap + 4).clamp(0.0, 32.0),
                            );
                      }
                    : null,
              ),
            ],
          )
        else
          IconButton(
            icon: FaIcon(
              settings.scaleType == .fitWidth
                  ? FontAwesomeIcons.arrowsLeftRight
                  : FontAwesomeIcons.arrowsUpDown,
            ),
            tooltip: 'Fit Direction',
            onPressed: () {
              ref.read(imageReaderSettingsProvider.notifier).toggleScaleType();
            },
          ),
      ],
    );
  }
}
