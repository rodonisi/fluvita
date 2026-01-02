import 'package:laya/api/models/progress_dto.dart';
import 'package:laya/models/book_model.dart';
import 'package:laya/riverpod/api/book.dart';
import 'package:laya/riverpod/api/client.dart';
import 'package:laya/riverpod/api/reader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'book.g.dart';

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
