import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:laya/api/models/progress_dto.dart';
import 'package:laya/riverpod/api.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:laya/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
sealed class BookModel with _$BookModel {
  const BookModel._();

  const factory BookModel({
    required int libraryId,
    required int seriesId,
    required int volumeId,
    required int chapterId,
    required String title,
    required int totalPages,
    required int currentPage,
    required Map<int, String> pages,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, Object?> json) =>
      _$BookModelFromJson(json);

  String get currentPageContent => pages[currentPage]!;
}

@riverpod
class Book extends _$Book {
  @override
  Future<BookModel> build({required int seriesId}) async {
    final chapter = await ref.watch(
      continuePointProvider(seriesId: seriesId).future,
    );
    final info = await ref.watch(
      bookInfoProvider(chapterId: chapter.id).future,
    );
    final progress = await ref.watch(
      bookProgressProvider(chapterId: chapter.id).future,
    );
    final page = await ref.watch(
      bookPageProvider(
        chapterId: chapter.id,
        page: progress.pageNum,
      ).future,
    );

    return BookModel(
      libraryId: info.libraryId,
      seriesId: info.seriesId,
      volumeId: info.volumeId,
      chapterId: chapter.id,
      title: info.seriesName ?? 'Untitled',
      totalPages: info.pages,
      currentPage: progress.pageNum,
      pages: {
        progress.pageNum: page,
      },
    );
  }

  Future<void> nextPage() async {
    final current = await future;
    await _gotoPage(current.currentPage + 1);
  }

  Future<void> previousPage() async {
    final current = await future;
    if (current.currentPage == 0) return;
    await _gotoPage(current.currentPage - 1);
  }

  Future<void> _gotoPage(int page) async {
    if (state.isLoading) return;
    final current = await future;

    state = AsyncValue.loading();

    if (page >= current.totalPages || page == current.currentPage || page < 0) {
      return;
    }

    final pages = Map<int, String>.from(current.pages);

    if (!pages.containsKey(page)) {
      pages[page] = await ref.watch(
        bookPageProvider(
          chapterId: current.chapterId,
          page: page,
        ).future,
      );
    }

    final readerClient = ref.read(restClientProvider).reader;
    await readerClient.postApiReaderProgress(
      body: ProgressDto(
        libraryId: current.libraryId,
        seriesId: current.seriesId,
        volumeId: current.volumeId,
        chapterId: current.chapterId,
        pageNum: page,
      ),
    );

    state = AsyncValue.data(
      current.copyWith(currentPage: page, pages: pages),
    );
  }
}
