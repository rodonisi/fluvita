import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/providers/chapter.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/riverpod/providers/router.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChapterCard extends HookConsumerWidget {
  const ChapterCard({
    super.key,
    required this.chapterId,
    required this.seriesId,
  });

  final int chapterId;
  final int seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider(chapterId: chapterId));
    final progress = ref
        .watch(chapterProgressProvider(chapterId: chapterId))
        .value;

    final markReadProvider = markChapterReadProvider(chapterId: chapterId);

    final isDownloaded =
        ref.watch(chapterDownloadedProvider(chapterId: chapterId)).value ??
        false;

    final downloadProgress = ref
        .watch(chapterDownloadProgressProvider(chapterId: chapterId))
        .value;

    final repo = ref.read(downloadRepositoryProvider);

    void Function()? onDownloadChapterAction;
    void Function()? onRemoveDownloadAction;

    if (isDownloaded) {
      onRemoveDownloadAction = () => repo.deleteChapter(
        chapterId: chapterId,
      );
    } else {
      onDownloadChapterAction = () => repo.downloadChapter(
        chapterId: chapterId,
      );
    }

    return Async(
      asyncValue: chapter,
      data: (chapter) => ActionsContextMenu(
        onMarkRead: () async {
          await ref.read(markReadProvider.notifier).markRead();
        },
        onMarkUnread: () async {
          await ref.read(markReadProvider.notifier).markUnread();
        },
        onDownloadChapter: onDownloadChapterAction,
        onRemoveDownload: onRemoveDownloadAction,
        child: CoverCard(
          title: chapter.title,
          coverImage: ChapterCoverImage(chapterId: chapterId),
          progress: progress,
          downloadStatusIcon: DownloadStatusIcon(
            progress: downloadProgress,
          ),
          onTap: () {
            ReaderRoute(
              seriesId: seriesId,
              chapterId: chapterId,
            ).push(context);
          },
        ),
      ),
    );
  }
}
