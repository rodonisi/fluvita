import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:laya/riverpod/api.dart';
import 'package:laya/riverpod/settings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlController = useTextEditingController();
    final apiKeyController = useTextEditingController();

    // Initialize controllers with current settings if available
    final settingsAsync = ref.watch(settingsProvider);

    useEffect(() {
      if (settingsAsync.hasValue) {
        final settings = settingsAsync.value!;
        if (urlController.text.isEmpty && settings.url != null) {
          urlController.text = settings.url!;
        }
        if (apiKeyController.text.isEmpty && settings.apiKey != null) {
          apiKeyController.text = settings.apiKey!;
        }
      }
      return null;
    }, [settingsAsync.hasValue]);

    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Kavita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://kavita.example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                helperText: 'Found in User Settings > API Key',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final apiKey = apiKeyController.text;
                if (apiKey.startsWith('http://') ||
                    apiKey.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'API Key should not be a URL. Please check your input.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                ref
                    .read(settingsProvider.notifier)
                    .updateSetting(
                      SettingsState(
                        url: urlController.text,
                        apiKey: apiKey,
                      ),
                    );
              },
              child: const Text('Connect'),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: currentUserAsync.when(
                data: (user) {
                  if (user == null) {
                    return const Center(child: Text('Not connected'));
                  }
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Connected as: ${user.username}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${user.email}'),
                          if (user.kavitaVersion != null)
                            Text('Server Version: ${user.kavitaVersion}'),
                        ],
                      ),
                    ),
                  );
                },
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
