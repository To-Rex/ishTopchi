import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/modules/main/views/skeleton_post_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../common/widgets/refresh_component.dart';
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
    final RefreshController refreshController = RefreshController(initialRefresh: false);
    final ScrollController scrollController = ScrollController();

    // Refresh hodisasi
    void onRefresh() async {
      funcController.currentPage.value = 1;
      funcController.hasMore.value = true;
      funcController.posts.clear();
      await apiController.fetchPosts(search: funcController.searchQuery.value, page: 1);
      refreshController.refreshCompleted();
    }

    // Infinite scroll hodisasi
    void onLoading() async {
      if (funcController.hasMore.value && !funcController.isLoading.value) {
        funcController.currentPage.value++;
        await apiController.fetchPosts(page: funcController.currentPage.value, search: funcController.searchQuery.value);
      }
      refreshController.loadComplete();
    }

    return Column(
      children: [
        Container(
          height: Responsive.scaleHeight(55, context),
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: Responsive.scaleHeight(10, context), left: Responsive.scaleWidth(16, context), right: Responsive.scaleWidth(16, context), bottom: Responsive.scaleHeight(10, context)),
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
            onChanged: (value) async {
              funcController.searchQuery.value = value;
              funcController.currentPage.value = 1;
              funcController.hasMore.value = true;
              funcController.posts.clear();
              await apiController.fetchPosts(search: value, page: 1);
              refreshController.refreshCompleted();
            },
          ),
        ),
        //qo'shimcha sozlamalar masalan filterlar, grid, list, etc va boshqa
        Container(
          height: Responsive.scaleHeight(55, context),
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            left: Responsive.scaleWidth(16, context),
            right: Responsive.scaleWidth(16, context),
            bottom: Responsive.scaleHeight(10, context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(10, context)),
                decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(8.sp)),
                child: Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
                    SizedBox(width: 6.sp),
                    Text(funcController.userMe.value!.data!.district!.region!.name.toString(), style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500))
                  ]
                )
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  //_showFilterDialog(context, funcController, apiController);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(12, context), vertical: Responsive.scaleHeight(10, context)),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.listFilter, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
                      SizedBox(width: 6.sp),
                      Text(
                        'Filtr'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ),
              SizedBox(width: 10.sp),
              GestureDetector(
                onTap: () {
                  //funcController.isGridView.value = !funcController.isGridView.value;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(10, context)),
                  decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(8.sp)),
                  child: Icon(LucideIcons.list, color: AppColors.lightGray, size: Responsive.scaleFont(20, context))
                )
              )
            ]
          )
        ),
        Expanded(
          child: RefreshComponent(
            refreshController: refreshController,
            scrollController: scrollController,
            color: AppColors.lightGray,
            onRefresh: onRefresh,
            onLoading: onLoading,
            enablePullUp: funcController.hasMore.value,
            child: Obx(() {
              debugPrint('Posts uzunligi: ${funcController.posts.length}');
              if (funcController.isLoading.value && funcController.posts.isEmpty) {
                // Skeleton ko‘rsatish
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(left: Responsive.scaleWidth(16, context), right: Responsive.scaleWidth(16, context), bottom: Responsive.scaleHeight(16, context)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.screenWidth(context) < 300 ? 1 : 2,
                    crossAxisSpacing: Responsive.scaleWidth(16, context),
                    mainAxisSpacing: Responsive.scaleHeight(16, context),
                    childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.6
                  ),
                  itemCount: 6,
                  // 6 ta skeleton kartochka ko‘rsatish
                  itemBuilder: (context, index) => const SkeletonPostCard()
                );
              } else if (funcController.posts.isEmpty) {
                // Postlar mavjud bo‘lmaganda matn doimo o‘rtada
                return SizedBox.expand(child: Center(child: Text('Postlar mavjud emas', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w500))));
              }
              // Postlar mavjud bo‘lganda
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: Responsive.scaleWidth(16, context),
                  right: Responsive.scaleWidth(16, context),
                  bottom: Responsive.scaleHeight(16, context),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Responsive.screenWidth(context) < 300 ? 1 : 2,
                  crossAxisSpacing: Responsive.scaleWidth(16, context),
                  mainAxisSpacing: Responsive.scaleHeight(16, context),
                  childAspectRatio:
                      Responsive.screenWidth(context) < 300 ? 0.9 : 0.6,
                ),
                itemCount: funcController.posts.length,
                itemBuilder: (context, index) {
                  final post = funcController.posts[index];
                  return PostCard(post: post);
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
