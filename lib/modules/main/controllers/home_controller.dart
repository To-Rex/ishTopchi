import 'package:get/get.dart';
import 'package:dio/dio.dart';

class HomeController extends GetxController {
  final Dio _dio = Dio();

  final RxList posts = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;

  int page = 1;
  final int limit = 10;
  String searchQuery = '';

  final RxString currentQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts(reset: true);
  }

  Future<void> fetchPosts({bool reset = false}) async {
    if (reset) {
      page = 1;
      posts.clear();
      hasMore.value = true;
      isLoading.value = true;
    } else {
      if (!hasMore.value) return;
      isMoreLoading.value = true;
    }

    try {
      final response = await _dio.get(
        'https://ishtopchi.uz/api/posts',
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': searchQuery,
        },
      );

      final List data = response.data['data'];

      if (data.length < limit) hasMore.value = false;

      posts.addAll(data);
      page++;
    } catch (e) {
      print('Xatolik: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value.trim();
    currentQuery.value = searchQuery;
    fetchPosts(reset: true);
  }
}
