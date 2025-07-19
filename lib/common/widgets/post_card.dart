import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/api_controller.dart';
import '../../controllers/funcController.dart';
import '../../core/models/post_model.dart';
import '../../core/utils/responsive.dart';
import '../../config/theme/app_colors.dart';
import '../../modules/main/views/post_detail_screen.dart';

class PostCard extends StatelessWidget {
  final post;
  final bool mePost;
  const PostCard({super.key, required this.post, required this.mePost});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();
    final screenWidth = Responsive.screenWidth(context);
    final isSmallScreen = screenWidth < 400;

    ApiController().fetchPostById(post.id);
    return Obx(() => funcController.isGridView.value ? _buildGridView(context, apiController, funcController, isSmallScreen) : _buildListView(context, apiController, funcController, isSmallScreen));
  }

  // Grid ko'rinishi uchun
  Widget _buildGridView(BuildContext context, ApiController apiController, FuncController funcController, bool isSmallScreen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context))),
      color: AppColors.darkBlue,
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(8, context), vertical: Responsive.scaleHeight(8, context)),
      child: InkWell(
        onTap: () {
          final dataPost = post is Data ? post as Data : Data.fromJson(post.toJson());
          Get.to(() => PostDetailScreen(post: dataPost));
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
                    decoration: BoxDecoration(color: AppColors.lightGray.withAlpha(50)),
                    child: post.pictureUrl != null && post.pictureUrl!.isNotEmpty
                        ? Image.network(
                      post.pictureUrl!.startsWith('http') ? post.pictureUrl! : 'https://ishtopchi.uz${post.pictureUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.imageOff, color: AppColors.darkBlue, size: 40)),
                    )
                        : const Center(child: Icon(LucideIcons.imageOff, color: AppColors.darkBlue, size: 40)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.title ?? 'Noma’lum', maxLines: isSmallScreen ? 1 : 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 14 : 16, context), fontWeight: FontWeight.bold, color: AppColors.white)),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Kategoriya va ish turi
                      Row(
                        children: [
                          if (post.category != null)
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(2, context)),
                                decoration: BoxDecoration(color: AppColors.darkNavy, borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)), border: Border.all(color: AppColors.lightBlue)),
                                child: Text(post.category!.title ?? 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600))
                              )
                            )
                          else
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(2, context)),
                                decoration: BoxDecoration(color: AppColors.darkNavy, borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)), border: Border.all(color: AppColors.lightBlue)),
                                child: Text('Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600))
                              )
                            ),
                          if (post.jobType != null) SizedBox(width: Responsive.scaleWidth(8, context)),
                          if (post.jobType != null)
                            Expanded(child: Text(post.jobType == 'FULL_TIME' ? 'To‘liq ish kuni' : post.jobType == 'TEMPORARY' ? 'Vaqtinchalik ish' : post.jobType == 'REMOTE' ? 'Masofaviy ish' : post.jobType == 'DAILY' ? 'Kunlik ish' : post.jobType == 'PROJECT_BASED' ? 'Loyihaviy ish' : post.jobType == 'INTERNSHIP' ? 'Amaliyot' : 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 11, context), color: AppColors.lightGray)))
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Tavsif
                      Container(
                        height: Responsive.scaleHeight(isSmallScreen ? 40 : 50, context),
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.darkNavy, borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context))),
                        padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                        child: Text(post.content ?? 'Tavsif yo‘q', maxLines: isSmallScreen ? 2 : 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray, height: 1.3))
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Maosh
                      Row(
                        children: [
                          Icon(LucideIcons.wallet, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Expanded(child: Text('${post.salaryFrom ?? 'Noma’lum'} - ${post.salaryTo ?? 'Noma’lum'} UZS', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600)))
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Tuman
                      Row(
                        children: [
                          Icon(LucideIcons.mapPin, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Expanded(child: Text(post.district?.name ?? 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue)))
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Foydalanuvchi
                      Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.scaleWidth(isSmallScreen ? 10 : 12, context),
                            backgroundImage: NetworkImage(funcController.getProfileUrl(post.user?.profilePicture)),
                            backgroundColor: AppColors.darkBlue,
                            child: post.user?.profilePicture == null ? Icon(LucideIcons.user, size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray) : null
                          ),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Flexible(child: Text('${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.white, fontWeight: FontWeight.w500)))
                        ]
                      ),
                      SizedBox(height: Responsive.scaleHeight(6, context)),
                      // Yaratilgan sana va ko'rishlar
                      Row(
                        children: [
                          Expanded(child: Text(post.createdAt != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(post.createdAt!)).toString() : 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 8 : 10, context), color: AppColors.lightGray))),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Icon(LucideIcons.eye, size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray),
                          SizedBox(width: Responsive.scaleWidth(4, context)),
                          Text('${post.views ?? 0} ko‘rish', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightGray))
                        ]
                      ),
                      //taxrirlash tugmasi
                      if (mePost)
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                      if (mePost)
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.lightBlue,
                            minimumSize: Size(double.infinity, Responsive.scaleHeight(isSmallScreen ? 25 : 30, context)),
                            padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(8, context), vertical: Responsive.scaleHeight(13, context)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)))
                          ),
                          child: Text('Tahrirlash'.tr, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.white)),
                          onPressed: () {
                            Get.back();
                            funcController.setBarIndex(2);
                          }
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
              child: mePost ?  CircleAvatar(
                  radius: Responsive.scaleWidth(isSmallScreen ? 18 : 20, context),
                  backgroundColor: AppColors.darkBlue,
                  child: IconButton(
                      icon: Icon(Icons.delete, color: AppColors.red, size: Responsive.scaleFont(isSmallScreen ? 18 : 20, context)),
                      onPressed: () async {
                        //await apiController.deletePost(post.id!.toInt());
                      }
                  )
              ) : Obx(() {
                  final isFavorite = funcController.wishList.any((w) => w.id == post.id);
                  return CircleAvatar(
                      radius: Responsive.scaleWidth(isSmallScreen ? 18 : 20, context),
                      backgroundColor: AppColors.darkBlue,
                      child: IconButton(
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.red : AppColors.white, size: Responsive.scaleFont(isSmallScreen ? 18 : 20, context)),
                          onPressed: () async {
                            if (isFavorite) {
                              await apiController.removeFromWishlist(post.id!.toInt());
                            } else {
                              await apiController.addToWishlist(post.id!.toInt());
                            }
                          }
                      )
                  );
              })
            )
          ]
        )
      )
    );
  }

  // List ko'rinishi uchun
  Widget _buildListView(BuildContext context, ApiController apiController, FuncController funcController, bool isSmallScreen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context))),
      color: AppColors.darkBlue,
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(8, context), vertical: Responsive.scaleHeight(8, context)),
      child: InkWell(
        onTap: () {
          final dataPost = post is Data ? post as Data : Data.fromJson(post.toJson());
          Get.to(() => PostDetailScreen(post: dataPost));
        },
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Surat
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(Responsive.scaleWidth(16, context))),
                  child: Container(
                    width: Responsive.scaleWidth(isSmallScreen ? 170 : 190, context),
                    height: Responsive.scaleHeight(isSmallScreen ? 170 : 190, context),
                    decoration: BoxDecoration(color: AppColors.lightGray.withAlpha(50)),
                    child: post.pictureUrl != null && post.pictureUrl!.isNotEmpty ? Image.network(
                      post.pictureUrl!.startsWith('http') ? post.pictureUrl! : 'https://ishtopchi.uz${post.pictureUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(LucideIcons.imageOff, color: AppColors.darkBlue, size: 40)),
                    ) : const Center(child: Icon(LucideIcons.imageOff, color: AppColors.darkBlue, size: 40))
                  )
                ),
                SizedBox(width: Responsive.scaleWidth(8, context)),
                // Ma'lumotlar
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sarlavha
                        Text(post.title ?? 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 14 : 16, context), fontWeight: FontWeight.bold, color: AppColors.white)),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Kategoriya va ish turi
                        Row(
                          children: [
                            if (post.category != null)
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(2, context)),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkNavy,
                                    borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                                    border: Border.all(color: AppColors.lightBlue)
                                  ),
                                  child: Text(
                                    post.category!.title ?? 'Noma’lum',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600)
                                  )
                                )
                              )
                            else
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(2, context)),
                                  decoration: BoxDecoration(color: AppColors.darkNavy, borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)), border: Border.all(color: AppColors.lightBlue)),
                                  child: Text('Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600))
                                )
                              ),
                            if (post.jobType != null) SizedBox(width: Responsive.scaleWidth(8, context)),
                            if (post.jobType != null)
                              Expanded(
                                child: Text(
                                  post.jobType == 'FULL_TIME' ? 'To‘liq ish kuni' : post.jobType == 'TEMPORARY' ? 'Vaqtinchalik ish' : post.jobType == 'REMOTE' ? 'Masofaviy ish' : post.jobType == 'DAILY' ? 'Kunlik ish' : post.jobType == 'PROJECT_BASED' ? 'Loyihaviy ish' : post.jobType == 'INTERNSHIP' ? 'Amaliyot' : 'Noma’lum',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 11, context), color: AppColors.lightGray)
                                )
                              )
                          ]
                        ),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Tavsif
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.darkNavy, borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context))),
                          padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
                          child: Text(
                            post.content ?? 'Tavsif yo‘q',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray, height: 1.3)
                          )
                        ),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Maosh
                        Row(
                          children: [
                            Icon(LucideIcons.wallet, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                            SizedBox(width: Responsive.scaleWidth(4, context)),
                            Expanded(child: Text('${post.salaryFrom ?? 'Noma’lum'} - ${post.salaryTo ?? 'Noma’lum'} UZS', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600)))
                          ]
                        ),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Tuman
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin, size: Responsive.scaleFont(isSmallScreen ? 12 : 14, context), color: AppColors.lightBlue),
                            SizedBox(width: Responsive.scaleWidth(4, context)),
                            Expanded(child: Text(post.district?.name ?? 'Noma’lum', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightBlue)))
                          ]
                        ),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Foydalanuvchi
                        Row(
                          children: [
                            CircleAvatar(
                              radius: Responsive.scaleWidth(isSmallScreen ? 10 : 12, context),
                              backgroundImage: NetworkImage(funcController.getProfileUrl(post.user?.profilePicture)),
                              backgroundColor: AppColors.darkBlue,
                              child: post.user?.profilePicture == null ? Icon(LucideIcons.user, size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray) : null
                            ),
                            SizedBox(width: Responsive.scaleWidth(4, context)),
                            Expanded(child: Text('${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.white, fontWeight: FontWeight.w500)))
                          ]
                        ),
                        SizedBox(height: Responsive.scaleHeight(6, context)),
                        // Yaratilgan sana va ko'rishlar
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                post.createdAt != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(post.createdAt!)).toString() : 'Noma’lum',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 8 : 10, context), color: AppColors.lightGray)
                              )
                            ),
                            SizedBox(width: Responsive.scaleWidth(4, context)),
                            Icon(LucideIcons.eye, size: Responsive.scaleFont(isSmallScreen ? 10 : 12, context), color: AppColors.lightGray),
                            SizedBox(width: Responsive.scaleWidth(4, context)),
                            Text('${post.views ?? 0} ko‘rish', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end, style: TextStyle(fontSize: Responsive.scaleFont(isSmallScreen ? 9 : 10, context), color: AppColors.lightGray))
                          ]
                        ),
                        if (mePost)
                          SizedBox(height: Responsive.scaleHeight(6, context)),
                        if (mePost)
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.lightBlue,
                              padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(8, context)),
                              minimumSize: Size(double.infinity, Responsive.scaleHeight(40, context)),
                              maximumSize: Size(double.infinity, Responsive.scaleHeight(40, context)),
                              alignment: Alignment.center,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)))
                            ),
                            child: Text('Tahrirlash'.tr, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(isSmallScreen ? 12 : 14, context))),
                            onPressed: () {
                              Get.back();
                              funcController.setBarIndex(2);
                            }
                          )
                        
                      ]
                    )
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
                if (mePost){
                  return CircleAvatar(
                    radius: Responsive.scaleWidth(isSmallScreen ? 18 : 20, context),
                    backgroundColor: AppColors.darkBlue,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: AppColors.red, size: Responsive.scaleFont(isSmallScreen ? 18 : 20, context)),
                      onPressed: () async {
                        //await apiController.deletePost(post.id!.toInt());
                      }
                    )
                  );
                } else {
                  return CircleAvatar(
                  radius: Responsive.scaleWidth(isSmallScreen ? 18 : 20, context),
                  backgroundColor: AppColors.darkBlue,
                  child: IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? AppColors.red : AppColors.white, size: Responsive.scaleFont(isSmallScreen ? 18 : 20, context)),
                    onPressed: () async {
                      if (isFavorite) {
                        await apiController.removeFromWishlist(post.id!.toInt());
                      } else {
                        await apiController.addToWishlist(post.id!.toInt());
                      }
                    }
                  )
                );
                }
              })
            )
          ]
        )
      )
    );
  }
}