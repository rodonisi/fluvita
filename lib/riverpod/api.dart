import 'package:dio/dio.dart';
import 'package:laya/api/export.dart';
import 'package:laya/riverpod/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api.g.dart';

@riverpod
class Jwt extends _$Jwt {
  @override
  String? build() {
    return ref.watch(currentUserProvider).value?.token;
  }
}

@riverpod
Dio dio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  return dio;
}

@riverpod
Dio authenticatedDio(Ref ref) {
  final dio = Dio();
  final settings = ref.watch(settingsProvider).value;
  final jwt = ref.watch(jwtProvider);

  if (settings?.url != null) {
    dio.options.baseUrl = settings!.url!;
  }

  dio.interceptors.add(
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (jwt != null && jwt.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $jwt';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

@riverpod
RestClient restClient(Ref ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return RestClient(dio);
}

@riverpod
AccountClient accountClient(Ref ref) {
  final dio = ref.watch(dioProvider);
  return RestClient(dio).account;
}

@riverpod
LibraryClient libraryClient(Ref ref) {
  return ref.watch(restClientProvider).library;
}

@riverpod
SeriesClient seriesClient(Ref ref) {
  return ref.watch(restClientProvider).series;
}

@riverpod
Future<UserDto?> currentUser(Ref ref) async {
  final settings = ref.watch(settingsProvider).value;
  final apiKey = settings?.apiKey;

  if (apiKey == null || apiKey.isEmpty) {
    return null;
  }

  final client = ref.watch(accountClientProvider);
  final user = await client.postApiAccountLogin(
    body: LoginDto(apiKey: apiKey, username: '', password: ''),
  );

  return user;
}

@riverpod
Future<List<LibraryDto>> libraries(Ref ref) async {
  final client = ref.watch(libraryClientProvider);
  return await client.getApiLibraryLibraries();
}

@riverpod
Future<List<SeriesDto>> series(Ref ref, int libraryId) async {
  final client = ref.watch(seriesClientProvider);
  return await client.postApiSeriesV2(
    body: FilterV2Dto(
      id: 0,
      combination: .value0,
      sortOptions: SortOptions(sortField: .value1, isAscending: false),
      limitTo: 20,
      statements: [
        FilterStatementDto(
          comparison: .value0,
          field: .value19,
          value: libraryId.toString(),
        ),
      ],
    ),
  );
}

@riverpod
Future<SeriesDetailDto> seriesDetail(Ref ref, int seriesID) async {
  final client = ref.watch(seriesClientProvider);
  return await client.getApiSeriesSeriesDetail(seriesId: seriesID);
}

@riverpod
Future<BookInfoDto> bookInfo(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).book;
  return await client.getApiBookChapterIdBookInfo(chapterId: chapterId);
}

@riverpod
Future<ChapterDto> continuePoint(Ref ref, {required int seriesId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderContinuePoint(seriesId: seriesId);
}

@riverpod
Future<ProgressDto> bookProgress(Ref ref, {required int chapterId}) async {
  final client = ref.watch(restClientProvider).reader;
  return await client.getApiReaderGetProgress(chapterId: chapterId);
}

@riverpod
Future<String> bookPage(Ref ref, {required int chapterId, int? page}) async {
  final client = ref.watch(restClientProvider).book;
  return await client.getApiBookChapterIdBookPage(
    chapterId: chapterId,
    page: page,
  );
}

@riverpod
Future<String> page(Ref ref, {required int seriesId}) async {
  final chapter = await ref.watch(
    continuePointProvider(seriesId: seriesId).future,
  );

  final progress = await ref.watch(
    bookProgressProvider(chapterId: chapter.id).future,
  );

  return ref.watch(
    bookPageProvider(
      chapterId: progress.chapterId,
      page: progress.pageNum,
    ).future,
  );
}
