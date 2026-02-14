import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/modules/main/views/skeleton_post_card.dart';
import 'package:ishtopchi/modules/profile/views/edit_profile_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../common/widgets/post_card.dart';
import '../../../common/widgets/refresh_component.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();
    final ApiController apiController = Get.find<ApiController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final RefreshController refreshController = RefreshController(
      initialRefresh: false,
    );
    final ScrollController scrollController = ScrollController();

    // Refresh hodisasi
    void onRefresh() async {
      funcController.currentPage.value = 1;
      funcController.hasMore.value = true;
      funcController.posts.clear();
      await apiController.fetchPosts(
        search: funcController.searchQuery.value,
        page: 1,
      );
      refreshController.refreshCompleted();
    }

    // Infinite scroll hodisasi
    void onLoading() async {
      if (funcController.hasMore.value && !funcController.isLoading.value) {
        funcController.currentPage.value++;
        await apiController.fetchPosts(
          page: funcController.currentPage.value,
          search: funcController.searchQuery.value,
        );
      }
      refreshController.loadComplete();
    }

    void showFilterDialog(
      BuildContext context,
      FuncController funcController,
      ApiController apiController,
    ) {
      if (funcController.regions.isEmpty) {
        apiController.fetchRegions().then((regions) {
          funcController.regions.assignAll(regions);
          if (regions.isNotEmpty &&
              funcController.selectedRegion.value == null) {
            funcController.selectedRegion.value = regions.first['id'] as int;
            apiController
                .fetchDistricts(funcController.selectedRegion.value!)
                .then((districts) {
                  funcController.districts.assignAll(districts);
                  if (districts.isNotEmpty &&
                      funcController.selectedDistrict.value == null) {
                    funcController.selectedDistrict.value =
                        districts.first['id'] as int;
                  }
                });
          }
        });
      }
      if (funcController.categories.isEmpty) {
        apiController.fetchCategories().then((categories) {
          funcController.categories.assignAll(categories);
        });
      }

      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder:
            (context, anim1, anim2) => Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: double.infinity * 0.95,
                minWidth: double.infinity * 0.9,
                maxHeight: double.infinity * 0.8,
              ),
              child: AlertDialog(
                backgroundColor: AppColors.backgroundColor,
                title: Text(
                  'Filtrolash'.tr,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: Responsive.scaleFont(20, context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                elevation: 8,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.scaleWidth(20, context),
                  vertical: Responsive.scaleHeight(20, context),
                ),
                content: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField2<int>(
                          value: funcController.selectedRegion.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            label: Container(
                              margin: EdgeInsets.only(
                                left: Responsive.scaleWidth(20, context),
                              ),
                              child: Text(
                                'Viloyat'.tr,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: Responsive.scaleFont(14, context),
                                ),
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            filled: true,
                            fillColor: AppColors.cardColor.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.iconColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                              right: Responsive.scaleWidth(15, context),
                              top: Responsive.scaleHeight(10, context),
                              bottom: Responsive.scaleHeight(10, context),
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 220.sp,
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(12.sp),
                              boxShadow:
                                  themeController.isDarkMode.value
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: AppColors.shadowColor,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            offset: Offset(0, -5.sp),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              LucideIcons.chevronDown,
                              color: AppColors.textSecondaryColor,
                              size: 20.sp,
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.w500,
                          ),
                          items:
                              funcController.regions
                                  .map(
                                    (region) => DropdownMenuItem<int>(
                                      value: region['id'] as int,
                                      child: Text(
                                        region['name'].toString(),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              funcController.selectedRegion.value = value;
                              funcController.districts.clear();
                              funcController.selectedDistrict.value = null;
                              funcController.isLoadingDistricts.value = true;
                              final districts = await apiController
                                  .fetchDistricts(value);
                              funcController.districts.assignAll(districts);
                              funcController.isLoadingDistricts.value = false;
                              if (districts.isNotEmpty) {
                                funcController.selectedDistrict.value =
                                    districts.first['id'] as int;
                              }
                            }
                          },
                          validator:
                              (value) =>
                                  value == null
                                      ? 'Iltimos, viloyatni tanlang'.tr
                                      : null,
                          hint: Text(
                            'Tanlang'.tr,
                            style: TextStyle(
                              color: AppColors.iconColor,
                              fontSize: Responsive.scaleFont(16, context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.sp),
                        // Tuman tanlash
                        funcController.isLoadingDistricts.value
                            ? SizedBox(
                              height: AppDimensions.buttonHeight,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.iconColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : DropdownButtonFormField2<int>(
                              value: funcController.selectedDistrict.value,
                              isExpanded: true,
                              decoration: InputDecoration(
                                label: Container(
                                  margin: EdgeInsets.only(
                                    left: Responsive.scaleWidth(20, context),
                                  ),
                                  child: Text(
                                    'Shahar/Tuman'.tr,
                                    style: TextStyle(
                                      color: AppColors.textSecondaryColor,
                                      fontSize: Responsive.scaleFont(
                                        14,
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: Responsive.scaleFont(14, context),
                                ),
                                filled: true,
                                fillColor: AppColors.cardColor.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.sp),
                                  borderSide: BorderSide(
                                    color: AppColors.iconColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.only(
                                  right: Responsive.scaleWidth(15, context),
                                  top: Responsive.scaleHeight(10, context),
                                  bottom: Responsive.scaleHeight(10, context),
                                ),
                                errorStyle: TextStyle(
                                  color: AppColors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 220.sp,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(12.sp),
                                  boxShadow:
                                      themeController.isDarkMode.value
                                          ? null
                                          : [
                                            BoxShadow(
                                              color: AppColors.shadowColor,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                ),
                                offset: Offset(0, -5.sp),
                              ),
                              iconStyleData: IconStyleData(
                                icon: Icon(
                                  LucideIcons.chevronDown,
                                  color: AppColors.textSecondaryColor,
                                  size: 20.sp,
                                ),
                              ),
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: Responsive.scaleFont(14, context),
                                fontWeight: FontWeight.w500,
                              ),
                              items:
                                  funcController.districts
                                      .map(
                                        (district) => DropdownMenuItem<int>(
                                          value: district['id'] as int,
                                          child: Text(
                                            district['name'].toString(),
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  funcController.selectedDistrict.value = value;
                                }
                              },
                              validator:
                                  (value) =>
                                      value == null
                                          ? 'Iltimos, shahar/tumanni tanlang'.tr
                                          : null,
                              hint: Text(
                                'Tanlang'.tr,
                                style: TextStyle(
                                  color: AppColors.iconColor,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        SizedBox(height: 16.sp),
                        // Narxdan
                        TextFormField(
                          initialValue: funcController.minPrice.value,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Narxdan'.tr,
                            labelStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            filled: true,
                            fillColor: AppColors.cardColor.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.iconColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.scaleWidth(20, context),
                              vertical: Responsive.scaleHeight(10, context),
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                            suffixText: 'UZS',
                            suffixStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                          ),
                          onChanged:
                              (value) =>
                                  funcController.minPrice.value =
                                      value.isEmpty ? null : value,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final numValue = double.tryParse(value);
                              if (numValue == null || numValue < 0) {
                                return "Iltimos, to'g'ri narx kiriting".tr;
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.sp),
                        // Narxgacha
                        TextFormField(
                          initialValue: funcController.maxPrice.value,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Narxgacha'.tr,
                            labelStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            filled: true,
                            fillColor: AppColors.cardColor.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.iconColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.scaleWidth(20, context),
                              vertical: Responsive.scaleHeight(10, context),
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                            suffixText: 'UZS',
                            suffixStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                          ),
                          onChanged:
                              (value) =>
                                  funcController.maxPrice.value =
                                      value.isEmpty ? null : value,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final numValue = double.tryParse(value);
                              if (numValue == null || numValue < 0) {
                                return "Iltimos, to'g'ri narx kiriting".tr;
                              }
                              final minPriceValue =
                                  funcController.minPrice.value != null
                                      ? double.tryParse(
                                        funcController.minPrice.value!,
                                      )
                                      : null;
                              if (minPriceValue != null &&
                                  numValue < minPriceValue) {
                                return "Narxgacha narxdan katta bo'lishi kerak"
                                    .tr;
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.sp),
                        // Ish turi tanlash
                        DropdownButtonFormField2<String>(
                          value: funcController.jobType.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            label: Container(
                              margin: EdgeInsets.only(
                                left: Responsive.scaleWidth(20, context),
                              ),
                              child: Text(
                                'Ish turi'.tr,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: Responsive.scaleFont(14, context),
                                ),
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            filled: true,
                            fillColor: AppColors.cardColor.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.iconColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                              right: Responsive.scaleWidth(20, context),
                              top: Responsive.scaleHeight(10, context),
                              bottom: Responsive.scaleHeight(10, context),
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 220.sp,
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(12.sp),
                              boxShadow:
                                  themeController.isDarkMode.value
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: AppColors.shadowColor,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            offset: Offset(0, -5.sp),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              LucideIcons.chevronDown,
                              color: AppColors.textSecondaryColor,
                              size: 20.sp,
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'FULL_TIME',
                              child: Text('kunlik'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'TEMPORARY',
                              child: Text('Yarim kunlik'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'REMOTE',
                              child: Text('Masofaviy'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'DAILY',
                              child: Text('Kunlik ish'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'PROJECT_BASED',
                              child: Text('Loyihaviy'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'INTERNSHIP',
                              child: Text('Amaliyot'.tr),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              funcController.jobType.value = value;
                            }
                          },
                          hint: Text(
                            'Tanlang'.tr,
                            style: TextStyle(
                              color: AppColors.iconColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.sp),
                        // Bandlik turi tanlash
                        DropdownButtonFormField2<String>(
                          value: funcController.employmentType.value,
                          isExpanded: true,
                          decoration: InputDecoration(
                            label: Container(
                              margin: EdgeInsets.only(
                                left: Responsive.scaleWidth(20, context),
                              ),
                              child: Text(
                                'Bandlik turi'.tr,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: Responsive.scaleFont(14, context),
                                ),
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            filled: true,
                            fillColor: AppColors.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                              borderSide: BorderSide(
                                color: AppColors.iconColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                              right: Responsive.scaleWidth(20, context),
                              top: Responsive.scaleHeight(10, context),
                              bottom: Responsive.scaleHeight(10, context),
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 220.sp,
                            decoration: BoxDecoration(
                              color: AppColors.cardColor,
                              borderRadius: BorderRadius.circular(12.sp),
                              boxShadow:
                                  themeController.isDarkMode.value
                                      ? null
                                      : [
                                        BoxShadow(
                                          color: AppColors.shadowColor,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                            ),
                            offset: Offset(0, -5.sp),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              LucideIcons.chevronDown,
                              color: AppColors.textSecondaryColor,
                              size: 20.sp,
                            ),
                          ),
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'FULL_TIME',
                              child: Text('kunlik'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'PART_TIME',
                              child: Text('Yarim kunlik'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'SHIFT_BASED',
                              child: Text('Smenali ish'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'FLEXIBLE',
                              child: Text('Moslashuvchan'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'REGULAR_SCHEDULE',
                              child: Text('Doimiy jadval'.tr),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              funcController.employmentType.value = value;
                            }
                          },
                          hint: Text(
                            'Tanlang'.tr,
                            style: TextStyle(
                              color: AppColors.iconColor,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      funcController.clearFilters();
                      funcController.currentPage.value = 1;
                      funcController.posts.clear();
                      funcController.hasMore.value = true;
                      apiController.fetchPosts(
                        page: 1,
                        search: funcController.searchQuery.value,
                      );
                      Get.back();
                    },
                    child: Text(
                      'Tozalash'.tr,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: Responsive.scaleFont(16, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      funcController.currentPage.value = 1;
                      funcController.posts.clear();
                      funcController.hasMore.value = true;
                      await apiController.fetchPosts(
                        page: 1,
                        search: funcController.searchQuery.value,
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      elevation: 0,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scaleWidth(20, context),
                        vertical: Responsive.scaleHeight(12, context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Text(
                        "Qo'llash".tr,
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: Responsive.scaleFont(16, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        transitionBuilder:
            (context, anim1, anim2, child) => FadeTransition(
              opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.easeOutBack,
                ),
                child: child,
              ),
            ),
      );
    }

    return Column(
      children: [
        Container(
          height: Responsive.scaleHeight(55, context),
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            top: Responsive.scaleHeight(10, context),
            left: Responsive.scaleWidth(16, context),
            right: Responsive.scaleWidth(16, context),
            bottom: Responsive.scaleHeight(10, context),
          ),
          child: Obx(
            () => TextField(
              decoration: InputDecoration(
                hintText: 'Qidirish...'.tr,
                hintStyle: TextStyle(color: AppColors.textSecondaryColor),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondaryColor,
                  size: Responsive.scaleFont(20, context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.scaleWidth(8, context),
                  ),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    themeController.isDarkMode.value
                        ? AppColors.darkBlue
                        : AppColors.cardColor,
              ),
              style: TextStyle(
                fontSize: Responsive.scaleFont(16, context),
                color: AppColors.textColor,
              ),
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
        ),
        // Qo'shimcha sozlamalar masalan filterlar, grid, list, etc va boshqa
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
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleWidth(12, context),
                    vertical: Responsive.scaleHeight(10, context),
                  ),
                  decoration: BoxDecoration(
                    color:
                        themeController.isDarkMode.value
                            ? AppColors.darkBlue
                            : AppColors.cardColor,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        color: AppColors.textSecondaryColor,
                        size: Responsive.scaleFont(20, context),
                      ),
                      SizedBox(width: 6.sp),
                      Obx(
                        () => Text(
                          funcController.userMe.value.data?.district != null
                              ? funcController
                                      .userMe
                                      .value
                                      .data
                                      ?.district
                                      ?.name ??
                                  'Viloyat'.tr
                              : 'Viloyat'.tr,
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.megaphone,
                        color: AppColors.textSecondaryColor,
                        size: Responsive.scaleFont(20, context),
                      ),
                      SizedBox(width: 6.sp),
                      Text(
                        '${funcController.totalPosts} ${'ta e’lon'.tr}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: Responsive.scaleFont(12, context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => GestureDetector(
                  onTap:
                      () => showFilterDialog(
                        context,
                        funcController,
                        apiController,
                      ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(12, context),
                      vertical: Responsive.scaleHeight(10, context),
                    ),
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode.value
                              ? AppColors.darkBlue
                              : AppColors.cardColor,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.listFilter,
                          color: AppColors.textSecondaryColor,
                          size: Responsive.scaleFont(20, context),
                        ),
                        SizedBox(width: 6.sp),
                        Text(
                          'Filtr'.tr,
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 3.sp),
                        Obx(
                          () =>
                              funcController.selectedRegion.value != null ||
                                      funcController.selectedDistrict.value !=
                                          null ||
                                      funcController.selectedCategory.value !=
                                          null ||
                                      funcController.employmentType.value !=
                                          null ||
                                      funcController.sortPrice.value != null ||
                                      funcController.minPrice.value != null ||
                                      funcController.maxPrice.value != null ||
                                      funcController.jobType.value != null
                                  ? CircleAvatar(
                                    radius: 3.sp,
                                    backgroundColor: AppColors.red,
                                  )
                                  : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.sp),
              Obx(
                () => GestureDetector(
                  onTap:
                      () =>
                          funcController.isGridView.value =
                              !funcController.isGridView.value,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(16, context),
                      vertical: Responsive.scaleHeight(10, context),
                    ),
                    decoration: BoxDecoration(
                      color:
                          themeController.isDarkMode.value
                              ? AppColors.darkBlue
                              : AppColors.cardColor,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Obx(
                      () => Icon(
                        !funcController.isGridView.value
                            ? LucideIcons.grid2x2
                            : LucideIcons.list,
                        color: AppColors.textSecondaryColor,
                        size: Responsive.scaleFont(20, context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshComponent(
            refreshController: refreshController,
            scrollController: scrollController,
            color: AppColors.textSecondaryColor,
            onRefresh: onRefresh,
            onLoading: onLoading,
            enablePullUp: funcController.hasMore.value,
            child: Obx(() {
              debugPrint(
                '${'Post uzunligi'.tr}: ${funcController.posts.length}',
              );
              if (funcController.isLoading.value &&
                  funcController.posts.isEmpty) {
                return funcController.isGridView.value
                    ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: Responsive.scaleWidth(16, context),
                        right: Responsive.scaleWidth(16, context),
                        bottom: Responsive.scaleHeight(16, context),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive().getCrossAxisCount(context),
                        crossAxisSpacing: Responsive.scaleWidth(16, context),
                        mainAxisSpacing: Responsive.scaleHeight(16, context),
                        childAspectRatio:
                            Responsive.screenWidth(context) < 300 ? 0.9 : 0.6,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => const SkeletonPostCard(),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: Responsive.scaleWidth(16, context),
                        right: Responsive.scaleWidth(16, context),
                        bottom: Responsive.scaleHeight(16, context),
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => const SkeletonPostCard(),
                    );
              } else if (funcController.posts.isEmpty) {
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
                              LucideIcons.fileText,
                              size: Responsive.scaleWidth(56, context),
                              color: AppColors.iconColor.withOpacity(0.6),
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(24, context)),
                          // Title
                          Text(
                            'Postlar mavjud emas'.tr,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: Responsive.scaleFont(20, context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(12, context)),
                          // Subtitle
                          Text(
                            'Postlar topilmadi tavsifi'.tr,
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
                            onTap: () {
                              funcController.currentPage.value = 1;
                              funcController.hasMore.value = true;
                              funcController.posts.clear();
                              apiController.fetchPosts(
                                search: funcController.searchQuery.value,
                                page: 1,
                              );
                            },
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
                                    color: AppColors.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.refreshCw,
                                    size: Responsive.scaleWidth(18, context),
                                    color: AppColors.white,
                                  ),
                                  SizedBox(
                                    width: Responsive.scaleWidth(8, context),
                                  ),
                                  Text(
                                    'Qayta yuklash'.tr,
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: Responsive.scaleFont(
                                        14,
                                        context,
                                      ),
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
              // Postlar mavjud bo'lganda
              return funcController.isGridView.value
                  ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: Responsive.scaleWidth(16, context),
                      right: Responsive.scaleWidth(16, context),
                      bottom: Responsive.scaleHeight(16, context),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Responsive().getCrossAxisCount(context),
                      crossAxisSpacing: Responsive.scaleWidth(16, context),
                      mainAxisSpacing: Responsive.scaleHeight(16, context),
                      childAspectRatio:
                          Responsive.screenWidth(context) < 300 ? 0.9 : 0.59,
                    ),
                    itemCount: funcController.posts.length,
                    itemBuilder: (context, index) {
                      final post = funcController.posts[index];
                      return PostCard(post: post, mePost: false);
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
                    itemCount: funcController.posts.length,
                    itemBuilder: (context, index) {
                      final post = funcController.posts[index];
                      return PostCard(post: post, mePost: false);
                    },
                  );
            }),
          ),
        ),
      ],
    );
  }
}
