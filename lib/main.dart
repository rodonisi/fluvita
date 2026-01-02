import 'package:flutter/material.dart';
import 'package:laya/riverpod/theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:laya/riverpod/router.dart';
import 'package:laya/widgets/async_value.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: const App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Async(
      asyncValue: ref.watch(themeProvider),
      data: (theme) => MaterialApp.router(
        title: 'Fluvita',
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.mode,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
