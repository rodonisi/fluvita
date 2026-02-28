import 'package:flutter/material.dart';
import 'package:fluvita/riverpod/managers/download_manager.dart';
import 'package:fluvita/riverpod/providers/download.dart';
import 'package:fluvita/riverpod/providers/reader.dart';
import 'package:fluvita/riverpod/providers/router.dart';
import 'package:fluvita/riverpod/providers/volume.dart';
import 'package:fluvita/riverpod/repository/download_repository.dart';
import 'package:fluvita/widgets/actions_menu.dart';
import 'package:fluvita/widgets/async_value.dart';
import 'package:fluvita/widgets/cover_card.dart';
import 'package:fluvita/widgets/cover_image.dart';
import 'package:fluvita/widgets/download_status_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumeCard extends HookConsumerWidget {
  const VolumeCard({
    super.key,
    required this.volumeId,
  });

  final int volumeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider(volumeId: volumeId));
    final progress = ref
        .watch(volumeProgressProvider(volumeId: volumeId))
        .value;

    final markReadProvider = markVolumeReadProvider(
      volumeId: volumeId,
    );

    final downloadProgress = ref
        .watch(volumeDownloadProgressProvider(volumeId: volumeId))
        .value;

    final isDownloaded = downloadProgress != null && downloadProgress >= 1.0;

    void Function()? onDownloadVolume;
    void Function()? onRemoveVolumeDownload;

    if (!isDownloaded) {
      onDownloadVolume = () =>
          ref.read(downloadManagerProvider.notifier).enqueueVolume(volumeId);
    } else {
      onRemoveVolumeDownload = () =>
          ref.read(downloadRepositoryProvider).deleteVolume(volumeId);
    }

    return Async(
      asyncValue: volume,
      data: (volume) => ActionsContextMenu(
        onMarkRead: () async {
          await ref.read(markReadProvider.notifier).markRead();
        },
        onMarkUnread: () async {
          await ref.read(markReadProvider.notifier).markUnread();
        },
        onDownloadVolume: onDownloadVolume,
        onRemoveVolumeDownload: onRemoveVolumeDownload,
        child: CoverCard(
          title: volume.name,
          coverImage: VolumeCoverImage(volumeId: volume.id),
          progress: progress,
          downloadStatusIcon: DownloadStatusIcon(
            progress: downloadProgress,
          ),
          onRead: () {
            if (volume.chapters.isNotEmpty) {
              ReaderRoute(
                seriesId: volume.seriesId,
                chapterId: volume.chapters.first.id,
              ).push(context);
            }
          },
          onTap: () {
            VolumeDetailRoute(volume).push(context);
          },
        ),
      ),
    );
  }
}
