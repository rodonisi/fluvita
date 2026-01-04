import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fluvita/riverpod/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      // retry: (retryCount, error) => null,
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Fluvita',
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
