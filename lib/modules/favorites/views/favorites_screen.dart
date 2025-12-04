import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../common/widgets/post_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Obx(() {
        print('WishList uzunligi: ${funcController.wishList.length}');
        if (funcController.getToken() == null ||
            funcController.getToken() == '') {
          return NotLogged();
        }
        return funcController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : funcController.wishList.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 54.sp,
                      color: AppColors.lightGray,
                    ),
                    const SizedBox(height: 16),
                    Text('Saqlangan postlar yo‘q'.tr, style: AppTheme.theme.textTheme.bodyMedium!.copyWith(color: AppColors.white, fontFamily: 'Poppins', fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Saqlangan postlar yo‘q tavsifi'.tr, style: AppTheme.theme.textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), backgroundColor: AppColors.darkBlue),
                      onPressed: () => funcController.setBarIndex(0),
                      child: Text('Asosiy sahifaga o‘tish'.tr)
                    )
                  ]
                )
              )
            )
            : funcController.isGridView.value
            ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive().getCrossAxisCount(context),
                crossAxisSpacing: Responsive.scaleWidth(16, context),
                mainAxisSpacing: Responsive.scaleHeight(16, context),
                childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.59,
              ),
              itemCount: funcController.wishList.length,
              itemBuilder: (context, index) {
                final wish = funcController.wishList[index];
                return PostCard(post: Data.fromJson(wish.toJson()), mePost: false);
              },
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: Responsive.scaleWidth(16, context),
                right: Responsive.scaleWidth(16, context),
                bottom: Responsive.scaleHeight(16, context),
              ),
              itemCount: funcController.wishList.length,
              itemBuilder: (context, index) {
                final wish = funcController.wishList[index];
                return PostCard(
                  post: Data.fromJson(wish.toJson()),
                  mePost: false,
                );
              },
            );
      }),
    );
  }
}
