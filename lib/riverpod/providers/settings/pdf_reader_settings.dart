import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:kover/models/read_direction.dart';
import 'package:kover/riverpod/repository/storage_repository.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_reader_settings.freezed.dart';
part 'pdf_reader_settings.g.dart';

sealed class EpubReaderSettingsLimits {
  static const double fontSizeMin = 8.0;
  static const double fontSizeMax = 64.0;
  static const double fontSizeStep = 1;

  static const double marginSizeMin = LayoutConstants.smallerPadding;
  static const double marginSizeMax = LayoutConstants.largestPadding;
  static const double marginSizeStep = 4;

  static const double lineHeightMin = 0.5;
  static const double lineHeightMax = 5.0;
  static const double lineHeightStep = 0.2;

  static const double wordSpacingMin = -10.0;
  static const double wordSpacingMax = 10.0;
  static const double wordSpacingStep = 0.5;

  static const double letterSpacingMin = -10.0;
  static const double letterSpacingMax = 10.0;
  static const double letterSpacingStep = 0.5;
}

enum PdfReaderMode {
  horizontal,
  vertical,
}

@freezed
sealed class PdfReaderSettingsState with _$PdfReaderSettingsState {
  const PdfReaderSettingsState._();
  const factory PdfReaderSettingsState({
    @Default(ReadDirection.leftToRight) ReadDirection readDirection,
    @Default(PdfReaderMode.vertical) PdfReaderMode readerMode,
  }) = _PdfReaderSettingsState;

  factory PdfReaderSettingsState.fromJson(Map<String, Object?> json) =>
      _$PdfReaderSettingsStateFromJson(json);
}

@riverpod
@JsonPersist()
class DefaultPdfReaderSettings extends _$DefaultPdfReaderSettings {
  @override
  Future<PdfReaderSettingsState> build() async {
    await persist(
      ref.watch(storageProvider.future),
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
    ).future;
    return state.value ?? const PdfReaderSettingsState();
  }

  void setDefault(PdfReaderSettingsState newDefault) {
    state = AsyncData(newDefault);
  }
}

@riverpod
@JsonPersist()
class PdfReaderSettings extends _$PdfReaderSettings {
  @override
  Future<PdfReaderSettingsState> build({required int seriesId}) async {
    await persist(
      ref.watch(storageProvider.future),
      options: const StorageOptions(cacheTime: StorageCacheTime.unsafe_forever),
    ).future;

    final defaults = await ref.watch(defaultPdfReaderSettingsProvider.future);
    return state.value ?? defaults;
  }

  Future<void> toggleReadDirection() async {
    final current = await future;

    state = AsyncData(
      current.copyWith(
        readDirection: current.readDirection == ReadDirection.leftToRight
            ? ReadDirection.rightToLeft
            : ReadDirection.leftToRight,
      ),
    );
  }

  Future<void> setReaderMode(PdfReaderMode newMode) async {
    final current = await future;

    state = AsyncData(
      current.copyWith(readerMode: newMode),
    );
  }

  Future<void> reset() async {
    final defaults = await ref.read(defaultPdfReaderSettingsProvider.future);
    state = AsyncData(defaults);
  }

  Future<void> setDefault() async {
    final current = await future;
    ref.read(defaultPdfReaderSettingsProvider.notifier).setDefault(current);
  }
}
