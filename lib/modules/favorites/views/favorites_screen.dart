import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
          return SizedBox.expand(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scaleWidth(32, context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container with gradient background
                    Container(
                      width: Responsive.scaleWidth(120, context),
                      height: Responsive.scaleWidth(120, context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.heart,
                        size: Responsive.scaleWidth(56, context),
                        color: AppColors.iconColor.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(24, context)),
                    // Title
                    Text(
                      'Saqlangan postlar yo‘q'.tr,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: Responsive.scaleFont(20, context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(12, context)),
                    // Subtitle
                    Text(
                      'Saqlangan postlar yo‘q tavsifi'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: Responsive.scaleFont(14, context),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(32, context)),
                    // Refresh button
                    InkWell(
                      onTap: () => funcController.setBarIndex(0),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.scaleWidth(24, context),
                          vertical: Responsive.scaleHeight(14, context),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor,
                              AppColors.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.arrowLeft,
                              size: Responsive.scaleWidth(18, context),
                              color: AppColors.white,
                            ),
                            SizedBox(width: Responsive.scaleWidth(8, context)),
                            Text(
                              'Asosiy sahifaga o‘tish'.tr,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: Responsive.scaleFont(14, context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
