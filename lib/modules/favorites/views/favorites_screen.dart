import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../../../config/theme/app_colors.dart';
import '../../main/views/main_content.dart';
import '../../main/widgets/post_card.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: const Text('Saqlanganlar', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.darkNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
            () {
          print('WishList uzunligi: ${funcController.wishList.length}'); // Debug uchun
          return funcController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : funcController.wishList.isEmpty
              ? const Center(
            child: Text(
              'Saqlangan postlar yo‘q',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: funcController.wishList.length,
            itemBuilder: (context, index) {
              final wish = funcController.wishList[index];
              return PostCard(post: wish.post);
            },
          );
        },
      ),
    );
  }
}