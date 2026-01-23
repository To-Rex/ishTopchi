import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../common/widgets/post_card.dart';

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
    final ThemeController themeController = Get.find<ThemeController>();

    // Check token outside Obx since it's not an observable
    if (funcController.getToken() == null || funcController.getToken() == '') {
      return Scaffold(body: NotLogged());
    }

    return Scaffold(
      body: Obx(() {
        // Show loading indicator while fetching
        if (funcController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show empty state if wishlist is empty
        if (funcController.wishList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 54.sp,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saqlangan postlar yo‘q'.tr,
                    style: AppTheme.theme.textTheme.bodyMedium!.copyWith(
                      color: AppColors.textColor,
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saqlangan postlar yo‘q tavsifi'.tr,
                    style: AppTheme.theme.textTheme.bodyMedium!.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      backgroundColor: AppColors.cardColor,
                    ),
                    onPressed: () => funcController.setBarIndex(0),
                    child: Text(
                      'Asosiy sahifaga o‘tish'.tr,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show wishlist posts
        return funcController.isGridView.value
            ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive().getCrossAxisCount(context),
                crossAxisSpacing: Responsive.scaleWidth(16, context),
                mainAxisSpacing: Responsive.scaleHeight(16, context),
                childAspectRatio:
                    Responsive.screenWidth(context) < 300 ? 0.9 : 0.59,
              ),
              itemCount: funcController.wishList.length,
              itemBuilder: (context, index) {
                final wish = funcController.wishList[index];
                return PostCard(post: wish, mePost: false);
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
                return PostCard(post: wish, mePost: false);
              },
            );
      }),
    );
  }
}
