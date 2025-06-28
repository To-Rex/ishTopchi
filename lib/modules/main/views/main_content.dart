import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../widgets/post_card.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();
    final ApiController apiController = Get.find<ApiController>();
    final ScrollController scrollController = ScrollController();

    // Skroll hodisasini reaktiv tarzda boshqarish
    ever(funcController.currentPage, (page) {
      if (page > 1 && funcController.hasMore.value) {
        debugPrint('Yangi sahifa yuklanmoqda: $page, joriy uzunlik: ${funcController.posts.length}');
        apiController.fetchPosts(
          page: page,
          search: funcController.searchQuery.value,
        );
      }
    });

    // Skroll hodisasini qo‘shish
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !funcController.isLoading.value &&
          funcController.hasMore.value) {
        funcController.currentPage.value++;
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Qidirish...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              funcController.searchQuery.value = value;
              funcController.currentPage.value = 1;
              funcController.hasMore.value = true;
              funcController.posts.clear();
              apiController.fetchPosts(search: value, page: 1);
            },
          ),
        ),
        Expanded(
          child: Obx(() {
            debugPrint('Posts uzunligi: ${funcController.posts.length}');
            if (funcController.posts.isEmpty && funcController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (funcController.posts.isEmpty) {
              return const Center(child: Text('Postlar yo‘q', style: TextStyle(color: Colors.white)));
            }

            return GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: funcController.posts.length + (funcController.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == funcController.posts.length) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                final post = funcController.posts[index];
                return PostCard(post: post);
              },
            );
          }),
        ),
      ],
    );
  }
}