import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/pages/settings/credentials_settings.dart';
import 'package:laya/pages/settings/theme_settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            CredentialsSettings(),
            ThemeSettings(),
          ],
        ),
      ),
    );
  }
}
