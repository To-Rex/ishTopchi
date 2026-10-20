import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../common/widgets/post_card.dart';

/// Saqlangan eʼlonlar.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch wishlist when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ApiController apiController = Get.find<ApiController>();
      final FuncController funcController = Get.find<FuncController>();
      if (funcController.getToken() != null &&
          funcController.getToken()!.isNotEmpty) {
        apiController.fetchWishlist();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();

    // Check token outside Obx since it's not an observable
    if (funcController.getToken() == null || funcController.getToken() == '') {
      return AppScreen(title: 'Saqlanganlar'.tr, child: const NotLogged());
    }

    return AppScreen(
      title: 'Saqlanganlar'.tr,
      child: Obx(() {
        // Show loading indicator while fetching
        if (funcController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show empty state if wishlist is empty
        if (funcController.wishList.isEmpty) {
          return AppEmptyState(
            icon: LucideIcons.heart,
            title: 'Saqlangan postlar yo‘q'.tr,
            message: 'Saqlangan postlar yo‘q tavsifi'.tr,
            actionLabel: 'Asosiy sahifaga o‘tish'.tr,
            actionIcon: const Icon(LucideIcons.arrowLeft),
            onAction: () => funcController.setBarIndex(0),
          );
        }

        // Show wishlist posts
        return funcController.isGridView.value
            ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              gridDelegate: PostCard.gridDelegate(context),
              itemCount: funcController.wishList.length,
              itemBuilder: (context, index) {
                final wish = funcController.wishList[index];
                return AppReveal(
                  delay: AppReveal.step(index),
                  child: PostCard(post: wish, mePost: false),
                );
              },
            )
            // Ilgari `shrinkWrap: true` va `NeverScrollableScrollPhysics`
            // bilan edi — roʻyxat aylanmas, koʻp saqlangan eʼlon boʻlsa
            // ekrandan chiqib ketardi.
            : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              itemCount: funcController.wishList.length,
              itemBuilder: (context, index) {
                final wish = funcController.wishList[index];
                return AppReveal(
                  delay: AppReveal.step(index),
                  child: PostCard(post: wish, mePost: false),
                );
              },
            );
      }),
    );
  }
}
