import 'package:flutter/material.dart';
import 'package:laya/pages/library/chapters_page.dart';
import 'package:laya/pages/library/library_page.dart';
import 'package:laya/pages/library/reader_page.dart';
import 'package:laya/pages/library/series_page.dart';
import 'package:laya/pages/login_page.dart';
import 'package:laya/widgets/navigator_container.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

sealed class Routes {
  static const String dashboard = '/';
  static const String settings = '/settings';
  static const String seriesPath = '/series/:libraryId';
  static String series({required int libraryId}) => '/series/$libraryId';

  static const String readerPath = '/reader/:seriesId';
  static String reader({required int seriesId}) => '/reader/$seriesId';

  static const String chaptersPath = '/chapters/:seriesId';
  static String chapters({required int seriesId}) => '/chapters/$seriesId';
}

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.dashboard,
                builder: (context, state) => LibraryPage(),
                routes: [
                  GoRoute(
                    path: Routes.seriesPath,
                    builder: (context, state) {
                      final libraryId = int.parse(
                        state.pathParameters['libraryId']!,
                      );
                      return SeriesPage(libraryId: libraryId);
                    },
                    routes: [],
                  ),
                ],
              ),
              GoRoute(
                path: Routes.chaptersPath,
                builder: (context, state) {
                  final seriesId = int.parse(
                    state.pathParameters['seriesId']!,
                  );
                  return ChaptersPage(seriesId: seriesId);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => LoginPage(),
              ),
            ],
          ),
        ],
        builder: (context, state, navigationShell) => NavigatorContainer(
          navigationShell: navigationShell,
        ),
      ),
      GoRoute(
        path: Routes.readerPath,
        pageBuilder: (context, state) {
          final seriesId = int.parse(
            state.pathParameters['seriesId']!,
          );
          return MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: ReaderPage(seriesId: seriesId),
          );
        },
        // builder: (context, state) {
        //   final seriesId = int.parse(
        //     state.pathParameters['seriesId']!,
        //   );
        //   return ReaderPage(seriesId: seriesId);
        // },
      ),
    ],
  );
}
