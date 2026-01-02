import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

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
