import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../../../config/theme/app_colors.dart';
import '../views/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final dynamic post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();
    final screenWidth = Responsive.screenWidth(context);
    final isSmallScreen = screenWidth < 400;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
      ),
      color: AppColors.darkBlue,
      elevation: 4,
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.scaleWidth(8, context),
        vertical: Responsive.scaleHeight(8, context),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => PostDetailScreen(post: post));
        },
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(Responsive.scaleWidth(16, context))),
                  child: Container(
                    height: Responsive.scaleHeight(isSmallScreen ? 110 : 160, context),
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.lightGray.withOpacity(0.2)),
                    child: post.pictureUrl != null && post.pictureUrl.isNotEmpty ? Image.network(
                      post.pictureUrl.startsWith('http') ? post.pictureUrl : 'https://ishtopchi.uz${post.pictureUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          LucideIcons.imageOff,
                          color: AppColors.lightGray,
                          size: 40,
                        ),
                      ),
                    )
                        : const Center(
                      child: Icon(
                        LucideIcons.imageOff,
                        color: AppColors.lightGray,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        post.title ?? 'Noma’lum',
                        maxLines: isSmallScreen ? 1 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(isSmallScreen ? 14 : 16, context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Kategoriya
                      if (post.category != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.scaleWidth(12, context),
                            vertical: Responsive.scaleHeight(2, context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                            border: Border.all(color: AppColors.lightBlue),
                          ),
                          child: Text(
                            post.category!.title ?? 'Noma’lum',
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context),
                              color: AppColors.lightBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Tavsif
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                        ),
                        padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                        child: Text(
                          post.content ?? 'Tavsif yo‘q',
                          maxLines: isSmallScreen ? 2 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context),
                            color: AppColors.lightGray,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Maosh va Tuman
                      Row(
                        children: [
                          Icon(LucideIcons.wallet, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Expanded(
                            child: Text(
                              '${post.salaryFrom ?? 'Noma’lum'} - ${post.salaryTo ?? 'Noma’lum'} UZS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600)
                            )
                          )
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.mapPin, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Expanded(
                            child: Text(
                              post.district?.name ?? 'Noma’lum tuman',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue)
                            )
                          )
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Foydalanuvchi va ko'rishlar
                      Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.scaleWidth(isSmallScreen ? 10 : 12, context),
                            backgroundImage: NetworkImage(
                              funcController.getProfileUrl(post.user?.profilePicture),
                            ),
                            backgroundColor: AppColors.darkBlue,
                            child: post.user?.profilePicture == null
                                ? Icon(
                              LucideIcons.user,
                              size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context),
                              color: AppColors.lightGray,
                            )
                                : null,
                          ),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Expanded(
                            child: Text(
                              '${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context),
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Yaratilgan sana
                      Row(
                        children: [
                          Text('Yaratilgan: ${post.createdAt?.substring(0, 10) ?? 'Noma’lum'}', style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 8 : 10, context), color: AppColors.lightGray.withOpacity(0.7))),
                          Spacer(),
                          Icon(LucideIcons.eye, size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray),
                          SizedBox(width: Responsive.scaleWidth(3, context)),
                          Text('${post.views ?? 0} ko‘rish', style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightGray))
                        ]
                      )
                    ]
                  )
                )
              ]
            ),
            // Like tugmasi surat ustida
            Positioned(
              top: Responsive.scaleHeight(8, context),
              right: Responsive.scaleWidth(8, context),
              child: Obx(() {
                final isFavorite = funcController.wishList.any((w) => w.id == post.id);
                return CircleAvatar(
                  radius: Responsive.scaleWidth(isSmallScreen ? 18 : 20, context),
                  backgroundColor: AppColors.darkBlue.withOpacity(0.7),
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.red : AppColors.white,
                      size: Responsive.scaleFont(isSmallScreen ? 16 : 18, context),
                    ),
                    onPressed: () async {
                      print('Post ID: ${post.id}');
                      if (isFavorite) {
                        await apiController.removeFromWishlist(post.id!.toInt());
                      } else {
                        await apiController.addToWishlist(post.id!.toInt());
                      }
                    },
                  ),
                );
              }),
            )
          ]
        )
      )
    );
  }
}