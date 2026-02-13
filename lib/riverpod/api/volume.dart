import 'package:fluvita/models/volume_model.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'volume.g.dart';

@riverpod
@JsonPersist()
class Volume extends _$Volume {
  @override
  Future<VolumeModel> build({required int volumeId}) async {
    persist(ref.watch(storageProvider.future));

    final client = ref.watch(restClientProvider);
    final res = await client.apiVolumeGet(volumeId: volumeId);

    if (!res.isSuccessful || res.body == null) {
      throw Exception('Failed to load volume: ${res.error}');
    }

    return VolumeModel.fromVolumeDto(res.body!);
  }
}
