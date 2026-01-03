import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/models/read_direction.dart';
import 'package:laya/riverpod/epub_reader_settings.dart';
import 'package:laya/utils/layout_constants.dart';

class EpubReaderControls extends ConsumerWidget {
  const EpubReaderControls({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(epubReaderSettingsProvider);

    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.font),
          iconSize: LayoutConstants.smallIcon,
          tooltip: 'Decrease Font Size',
          onPressed: settings.canDecreaseFontSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .decreaseFontSize();
                }
              : null,
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.font),
          tooltip: 'Increase Font Size',
          onPressed: settings.canIncreaseFontSize
              ? () {
                  ref
                      .read(epubReaderSettingsProvider.notifier)
                      .increaseFontSize();
                }
              : null,
        ),
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.sliders),
          tooltip: 'Reader Settings',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (context) => const _ReaderSettingsBottomSheet(),
            );
          },
        ),
      ],
    );
  }
}

class _ReaderSettingsBottomSheet extends ConsumerWidget {
  const _ReaderSettingsBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(epubReaderSettingsProvider);
    final notifier = ref.read(epubReaderSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(
        left: LayoutConstants.mediumPadding,
        right: LayoutConstants.mediumPadding,
        bottom: LayoutConstants.largePadding,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        spacing: LayoutConstants.mediumPadding,
        children: [
          Text(
            'Reader Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            children: [
              const Expanded(child: Text('Read Direction')),
              SegmentedButton<ReadDirection>(
                segments: const [
                  ButtonSegment<ReadDirection>(
                    value: .leftToRight,
                    label: Text('LTR'),
                    icon: Icon(FontAwesomeIcons.anglesRight),
                  ),
                  ButtonSegment<ReadDirection>(
                    value: .rightToLeft,
                    label: Text('RTL'),
                    icon: Icon(FontAwesomeIcons.anglesLeft),
                  ),
                ],
                selected: {settings.readDirection},
                onSelectionChanged: (Set<ReadDirection> newSelection) {
                  if (newSelection.first != settings.readDirection) {
                    notifier.toggleReadDirection();
                  }
                },
              ),
            ],
          ),
          _SettingRow(
            label: 'Font Size',
            value: '${settings.fontSize.toInt()}',
            icon: FontAwesomeIcons.font,
            onDecrease: settings.canDecreaseFontSize
                ? notifier.decreaseFontSize
                : null,
            onIncrease: settings.canIncreaseFontSize
                ? notifier.increaseFontSize
                : null,
          ),
          _SettingRow(
            label: 'Margins',
            value: '${settings.marginSize.toInt()}',
            icon: FontAwesomeIcons.arrowsLeftRight,
            onDecrease: settings.canDecreaseMarginSize
                ? notifier.decreaseMarginSize
                : null,
            onIncrease: settings.canIncreaseMarginSize
                ? notifier.increaseMarginSize
                : null,
          ),
          _SettingRow(
            label: 'Line Height',
            value: settings.lineHeight.toStringAsFixed(1),
            icon: FontAwesomeIcons.textHeight,
            onDecrease: settings.canDecreaseLineHeight
                ? notifier.decreaseLineHeight
                : null,
            onIncrease: settings.canIncreaseLineHeight
                ? notifier.increaseLineHeight
                : null,
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: notifier.reset,
              icon: const FaIcon(FontAwesomeIcons.rotateLeft),
              label: const Text('Reset to Defaults'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(label),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onDecrease,
          icon: FaIcon(icon, size: LayoutConstants.smallIcon),
        ),
        const SizedBox(width: LayoutConstants.smallPadding),
        IconButton.filledTonal(
          onPressed: onIncrease,
          icon: FaIcon(icon),
        ),
      ],
    );
  }
}
