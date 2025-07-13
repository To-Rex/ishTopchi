import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../main/widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Obx(() {
        print('WishList uzunligi: ${funcController.wishList.length}');
        if (funcController.getToken() == null || funcController.getToken() == '') {
          return NotLogged();
        }
        return funcController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : funcController.wishList.isEmpty
            ? const Center(
          child: Text('Saqlangan postlar yo‘q', style: TextStyle(color: Colors.white, fontSize: 18)),
        ) : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.screenWidth(context) < 300 ? 1 : 2,
            crossAxisSpacing: Responsive.scaleWidth(16, context),
            mainAxisSpacing: Responsive.scaleHeight(16, context),
            childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.6,
          ),
          itemCount: funcController.wishList.length,
          itemBuilder: (context, index) {
            //final wish = funcController.wishList[index];
            //return PostCard(post: wish);
            final wish = funcController.wishList[index];
            return PostCard(post: Data.fromJson(wish.toJson()));
          },
        );
      }),
    );
  }
}