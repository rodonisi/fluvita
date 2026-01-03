import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/theme.dart' hide Theme;
import 'package:laya/utils/layout_constants.dart';
import 'package:laya/widgets/async_value.dart';

class ThemeSettings extends ConsumerWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Card(
      margin: LayoutConstants.largeEdgeInsets,
      child: Padding(
        padding: LayoutConstants.largeEdgeInsets,
        child: Async(
          asyncValue: theme,
          data: (data) {
            return Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              spacing: LayoutConstants.mediumPadding,
              children: [
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutConstants.mediumPadding,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const FaIcon(FontAwesomeIcons.palette),
                    title: const Text('Theme Mode'),
                    trailing: DropdownMenu<ThemeMode>(
                      initialSelection: data.mode,
                      leadingIcon: Icon(
                        switch (data.mode) {
                          ThemeMode.system => FontAwesomeIcons.circleHalfStroke,
                          ThemeMode.light => FontAwesomeIcons.solidSun,
                          ThemeMode.dark => FontAwesomeIcons.solidMoon,
                        },
                      ),
                      onSelected: (mode) {
                        if (mode != null) {
                          ref.read(themeProvider.notifier).setMode(mode);
                        }
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(
                          value: ThemeMode.system,
                          label: 'System',
                          leadingIcon: Icon(FontAwesomeIcons.circleHalfStroke),
                        ),
                        DropdownMenuEntry(
                          value: ThemeMode.light,
                          label: 'Light',
                          leadingIcon: Icon(FontAwesomeIcons.solidSun),
                        ),
                        DropdownMenuEntry(
                          value: ThemeMode.dark,
                          label: 'Dark',
                          leadingIcon: Icon(FontAwesomeIcons.solidMoon),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
