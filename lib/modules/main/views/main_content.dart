import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
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
        apiController.fetchPosts(page: page, search: funcController.searchQuery.value);
      }
    });

    // Skroll hodisasini qo‘shish
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !funcController.isLoading.value && funcController.hasMore.value) {funcController.currentPage.value++;}
    });

    return Column(
      children: [
        Container(
          height: Responsive.scaleHeight(55, context),
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            top: Responsive.scaleHeight(10, context),
            left: Responsive.scaleWidth(16, context),
            right: Responsive.scaleWidth(16, context),
            bottom: Responsive.scaleHeight(10, context)
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Qidirish...',
              hintStyle: TextStyle(color: AppColors.lightGray),
              prefixIcon: Icon(LucideIcons.search, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)), borderSide: BorderSide.none),
              filled: true,
              fillColor: AppColors.darkBlue
            ),
            style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightGray),
            onChanged: (value) {
              funcController.searchQuery.value = value;
              funcController.currentPage.value = 1;
              funcController.hasMore.value = true;
              funcController.posts.clear();
              apiController.fetchPosts(search: value, page: 1);
            }
          )
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
              padding: EdgeInsets.only(left: Responsive.scaleWidth(16, context), right: Responsive.scaleWidth(16, context)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.screenWidth(context) < 300 ? 1 : 2,
                crossAxisSpacing: Responsive.scaleWidth(16, context),
                mainAxisSpacing: Responsive.scaleHeight(16, context),
                childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.6
              ),
              itemCount: funcController.posts.length + (funcController.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == funcController.posts.length) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
                    alignment: Alignment.center,
                    child: const Center(child: CircularProgressIndicator())
                  );
                }
                final post = funcController.posts[index];
                return PostCard(post: post);
              }
            );
          })
        )
      ]
    );
  }
}