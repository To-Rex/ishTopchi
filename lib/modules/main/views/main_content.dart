import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/modules/main/views/post_card.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/home_controller.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        controller.fetchPosts(); // infinite scroll
      }
    });

    return Column(
      children: [
        // 🔍 Qidiruv maydoni
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: "Kasb, hudud yoki soha bo‘yicha qidirish...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),

        // 🔁 Postlar ro‘yxati
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.posts.isEmpty) {
              return const Center(child: Text("E'lon topilmadi."));
            }

            return ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: controller.posts.length + 1,
              itemBuilder: (context, index) {
                if (index < controller.posts.length) {
                  return PostCard(post: controller.posts[index]);
                } else {
                  return controller.isMoreLoading.value
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const SizedBox.shrink();
                }
              },
            );
          }),
        ),
      ],
    );
  }
}
