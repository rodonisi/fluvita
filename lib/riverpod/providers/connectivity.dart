import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluvita/riverpod/providers/client.dart';
import 'package:flutter/widgets.dart';
import 'package:fluvita/utils/lifecycle.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity.g.dart';

@riverpod
/// Returns wheter a connection to the server can be established.
Stream<bool> hasConnection(Ref ref) async* {
  final ping = ref.watch(pingProvider);
  final pingOk = ping.hasValue && ping.value!;

  final observer = LifecycleOnResumeObserver(
    onResume: () {
      if (ref.mounted) ref.invalidate(pingProvider);
    },
  );

  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));

  final current = await Connectivity().checkConnectivity();
  final hasInterface = !current.contains(ConnectivityResult.none);
  yield hasInterface && pingOk;

  await for (final results in Connectivity().onConnectivityChanged) {
    final online = !results.contains(ConnectivityResult.none);

    if (online && ref.mounted) ref.invalidate(pingProvider);

    yield online && pingOk;
  }
}

Duration? _neverRetry(int retryCount, Object error) => null;

@Riverpod(retry: _neverRetry)
Future<bool> ping(Ref ref) async {
  final client = ref.watch(restClientProvider);

  final timer = Timer(const Duration(minutes: 5), () {
    ref.invalidateSelf();
  });

  ref.onDispose(timer.cancel);

  final res = await client.apiAccountRefreshAccountGet();
  return res.isSuccessful;
}
