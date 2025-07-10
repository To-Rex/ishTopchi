import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../../config/theme/app_colors.dart';
import '../views/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();
    final screenWidth = Responsive.screenWidth(context);
    final isSmallScreen = screenWidth < 300;

    return Card(
      elevation: Responsive.scaleWidth(4, context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context))),
      color: AppColors.darkBlue,
      margin: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(8, context)),
      child: InkWell(
        onTap: () {
          // Postni ochish uchun qo‘shimcha logika qo‘shish mumkin
          Get.to(() => PostDetailScreen(post: post));
        },
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        post.title,
                        maxLines: isSmallScreen ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 14 : 18, context), fontWeight: FontWeight.bold, color: AppColors.white)
                      )
                    ),
                    Obx(() {
                      final isFavorite = funcController.wishList.any((w) => w.id == post.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.red : AppColors.lightGray,
                          size: Responsive.scaleFont(isSmallScreen ? 16 : 20, context),
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await apiController.removeFromWishlist(post.id.toInt());
                          } else {
                            await apiController.addToWishlist(post.id.toInt());
                          }
                        },
                        padding: EdgeInsets.all(Responsive.scaleWidth(2, context)),
                        constraints: BoxConstraints(minWidth: Responsive.scaleWidth(24, context), minHeight: Responsive.scaleHeight(24, context))
                      );
                    })
                  ]
                )
              ),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Text(
                  post.content,
                  maxLines: isSmallScreen ? 2 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightGray)
                )
              ),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${post.salaryFrom} - ${post.salaryTo} UZS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 14, context), fontWeight: FontWeight.w600, color: AppColors.lightBlue)
                        ),
                        SizedBox(height: Responsive.scaleHeight(4, context)),
                        Text(
                          post.district?.name ?? 'Noma’lum tuman',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 8 : 12, context), color: AppColors.lightBlue)
                        )
                      ]
                    )
                  )
                ]
              ),
              Spacer(),
              if (post.user != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: Responsive.scaleWidth(isSmallScreen ? 9 : 12, context), // Yumaloq rasm
                    //backgroundImage: NetworkImage(post.user?.profilePicture ?? ''),
                    backgroundImage: NetworkImage(FuncController().getProfileUrl(post.user?.profilePicture)),
                    backgroundColor: AppColors.darkBlue
                  ),
                  SizedBox(width: Responsive.scaleWidth(8, context)),
                  Expanded(
                    child: Text(
                      '${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(isSmallScreen ? 7 : 11, context),
                        color: AppColors.white,
                        fontWeight: FontWeight.w500
                      )
                    )
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}