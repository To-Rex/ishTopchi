import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../common/widgets/refresh_component.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../../main/views/skeleton_post_card.dart';
import '../../main/widgets/post_card.dart';

class MyPostsScreen extends StatefulWidget {
  MyPostsScreen({super.key});

  @override
  _MyPostsScreenState createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final FuncController funcController = Get.put(FuncController());
  final ApiController apiController = Get.find<ApiController>();
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Sahifani boshlang‘ich yuklashni kechiktirish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyPosts();
    });
  }

  // E‘lonlarni yuklash
  Future<void> _loadMyPosts() async {
    try {
      funcController.isLoading.value = true;
      await apiController.fetchMyPosts(
        page: funcController.currentPage.value,
        search: funcController.searchQuery.value,
      );
    } catch (e) {
      print('Xatolik: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowToast.show('Xatolik'.tr, e.toString(), 3, 1);
      });
    } finally {
      funcController.isLoading.value = false;
    }
  }

  // E‘lonlarni yangilash
  void _onRefresh() async {
    funcController.currentPage.value = 1;
    funcController.hasMore.value = true;
    funcController.mePosts.clear();
    await _loadMyPosts();
    refreshController.refreshCompleted();
  }

  // Qo‘shimcha e‘lonlarni yuklash
  void _onLoading() async {
    if (funcController.hasMore.value && !funcController.isLoading.value) {
      funcController.currentPage.value++;
      await _loadMyPosts();
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  // Grid uchun dinamik crossAxisCount hisoblash
  int _getCrossAxisCount(BuildContext context) {
    final width = Responsive.screenWidth(context);
    if (width > 1200) return 4; // Katta ekranlar (planshet, desktop)
    if (width > 600) return 3; // O‘rta ekranlar (planshet)
    return 2; // Telefonlar
  }

  // Filtr dialogi
  void showFilterDialog(BuildContext context, FuncController funcController, ApiController apiController) {
    // Viloyat va kategoriyalarni oldindan yuklash
    if (funcController.regions.isEmpty) {
      apiController.fetchRegions().then((regions) {
        funcController.regions.assignAll(regions);
        if (regions.isNotEmpty && funcController.selectedRegion.value == null) {
          funcController.selectedRegion.value = regions.first['id'] as int;
          apiController.fetchDistricts(funcController.selectedRegion.value!).then((districts) {
            funcController.districts.assignAll(districts);
            if (districts.isNotEmpty && funcController.selectedDistrict.value == null) {
              funcController.selectedDistrict.value = districts.first['id'] as int;
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
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: double.infinity * 0.95,
          minWidth: double.infinity * 0.9,
          maxHeight: double.infinity * 0.8,
        ),
        child: AlertDialog(
          backgroundColor: AppColors.darkNavy,
          title: Text(
            'Filtrolash'.tr,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Responsive.scaleFont(20, context),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
          elevation: 8,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleWidth(20, context),
            vertical: Responsive.scaleHeight(20, context),
          ),
          content: SingleChildScrollView(
            child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Viloyat tanlash
                DropdownButtonFormField2<int>(
                  value: funcController.selectedRegion.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: Container(
                      margin: EdgeInsets.only(left: Responsive.scaleWidth(20, context)),
                      child: Text(
                        'Viloyat'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    offset: Offset(0, -5.sp),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: 20.sp),
                  ),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                    fontWeight: FontWeight.w500,
                  ),
                  items: funcController.regions.map((region) {
                    return DropdownMenuItem<int>(
                      value: region['id'] as int,
                      child: Text(
                        region['name'].toString(),
                        maxLines: 1,
                        style: TextStyle(color: AppColors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      funcController.selectedRegion.value = value;
                      funcController.districts.clear();
                      funcController.selectedDistrict.value = null;
                      funcController.isLoadingDistricts.value = true;
                      final districts = await apiController.fetchDistricts(value);
                      funcController.districts.assignAll(districts);
                      funcController.isLoadingDistricts.value = false;
                      if (districts.isNotEmpty) {
                        funcController.selectedDistrict.value = districts.first['id'] as int;
                      }
                    }
                  },
                  validator: (value) => value == null ? 'Iltimos, viloyatni tanlang'.tr : null,
                  hint: Text(
                    'Tanlang'.tr,
                    style: TextStyle(
                      color: AppColors.lightBlue,
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
                      color: AppColors.lightBlue,
                      strokeWidth: 2,
                    ),
                  ),
                )
                    : DropdownButtonFormField2<int>(
                  value: funcController.selectedDistrict.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: Container(
                      margin: EdgeInsets.only(left: Responsive.scaleWidth(20, context)),
                      child: Text(
                        'Shahar/Tuman'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    offset: Offset(0, -5.sp),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: 20.sp),
                  ),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                    fontWeight: FontWeight.w500,
                  ),
                  items: funcController.districts.map((district) {
                    return DropdownMenuItem<int>(
                      value: district['id'] as int,
                      child: Text(
                        district['name'].toString(),
                        maxLines: 1,
                        style: TextStyle(color: AppColors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      funcController.selectedDistrict.value = value;
                    }
                  },
                  validator: (value) => value == null ? 'Iltimos, shahar/tumanni tanlang'.tr : null,
                  hint: Text(
                    'Tanlang'.tr,
                    style: TextStyle(
                      color: AppColors.lightBlue,
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
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Narxdan'.tr,
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                  onChanged: (value) => funcController.minPrice.value = value.isEmpty ? null : value,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final numValue = double.tryParse(value);
                      if (numValue == null || numValue < 0) {
                        return 'Iltimos, to‘g‘ri narx kiriting'.tr;
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
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Narxgacha'.tr,
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                  onChanged: (value) => funcController.maxPrice.value = value.isEmpty ? null : value,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final numValue = double.tryParse(value);
                      if (numValue == null || numValue < 0) {
                        return 'Iltimos, to‘g‘ri narx kiriting'.tr;
                      }
                      final minPriceValue = funcController.minPrice.value != null ? double.tryParse(funcController.minPrice.value!) : null;
                      if (minPriceValue != null && numValue != null && numValue < minPriceValue) {
                        return 'Narxgacha narxdan katta bo‘lishi kerak'.tr;
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.sp),
                // Ish turi tanlash
                DropdownButtonFormField2<String>(
                  value: funcController.employmentType.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    label: Container(
                      margin: EdgeInsets.only(left: Responsive.scaleWidth(20, context)),
                      child: Text(
                        'Ish turi'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    offset: Offset(0, -5.sp),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: 20.sp),
                  ),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                  items: [
                    DropdownMenuItem(value: 'FULL_TIME', child: Text('To‘liq kunlik'.tr)),
                    DropdownMenuItem(value: 'PART_TIME', child: Text('Yarim kunlik'.tr)),
                    DropdownMenuItem(value: 'REMOTE', child: Text('Masofaviy'.tr)),
                    DropdownMenuItem(value: 'DAILY', child: Text('Kunlik ish'.tr)),
                    DropdownMenuItem(value: 'PROJECT_BASED', child: Text('Loyihaviy asosda'.tr)),
                    DropdownMenuItem(value: 'INTERNSHIP', child: Text('Amaliyot (stajirovka)'.tr)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      funcController.employmentType.value = value;
                    }
                  },
                  hint: Text(
                    'Tanlang'.tr,
                    style: TextStyle(
                      color: AppColors.lightBlue,
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
                      margin: EdgeInsets.only(left: Responsive.scaleWidth(20, context)),
                      child: Text(
                        'Bandlik turi'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.lightGray,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.sp),
                      borderSide: BorderSide(color: AppColors.lightBlue, width: 2),
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
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    offset: Offset(0, -5.sp),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: 20.sp),
                  ),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                  items: [
                    DropdownMenuItem(value: 'FULL_TIME', child: Text('To‘liq kunlik'.tr)),
                    DropdownMenuItem(value: 'PART_TIME', child: Text('Yarim kunlik'.tr)),
                    DropdownMenuItem(value: 'REMOTE', child: Text('Masofaviy'.tr)),
                    DropdownMenuItem(value: 'DAILY', child: Text('Kunlik ish'.tr)),
                    DropdownMenuItem(value: 'PROJECT_BASED', child: Text('Loyihaviy asosda'.tr)),
                    DropdownMenuItem(value: 'INTERNSHIP', child: Text('Amaliyot (stajirovka)'.tr)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      funcController.employmentType.value = value;
                    }
                  },
                  hint: Text(
                    'Tanlang'.tr,
                    style: TextStyle(
                      color: AppColors.lightBlue,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                ),
              ],
            )),
          ),
          actions: [
            TextButton(
              onPressed: () {
                funcController.clearFilters();
                funcController.currentPage.value = 1;
                funcController.mePosts.clear();
                funcController.hasMore.value = true;
                apiController.fetchMyPosts(page: 1, search: funcController.searchQuery.value);
                Navigator.of(context).pop();
              },
              child: Text(
                'Tozalash'.tr,
                style: TextStyle(
                  color: AppColors.lightGray,
                  fontSize: Responsive.scaleFont(16, context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                funcController.currentPage.value = 1;
                funcController.mePosts.clear();
                funcController.hasMore.value = true;
                await apiController.fetchMyPosts(
                  page: 1,
                  search: funcController.searchQuery.value,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                elevation: 0,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scaleWidth(20, context),
                  vertical: Responsive.scaleHeight(12, context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Text(
                  'Qo‘llash'.tr,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(16, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, anim1, anim2, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.white, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mening e‘lonlarim'.tr,
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.scaleFont(20, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Qidiruv maydoni
          Container(
            height: Responsive.scaleHeight(55, context),
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              top: Responsive.scaleHeight(10, context),
              left: Responsive.scaleWidth(16, context),
              right: Responsive.scaleWidth(16, context),
              bottom: Responsive.scaleHeight(10, context),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Qidirish...'.tr,
                hintStyle: TextStyle(color: AppColors.lightGray),
                prefixIcon: Icon(LucideIcons.search, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.darkBlue,
              ),
              style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightGray),
              onChanged: (value) async {
                funcController.searchQuery.value = value;
                funcController.currentPage.value = 1;
                funcController.hasMore.value = true;
                funcController.mePosts.clear();
                await _loadMyPosts();
                refreshController.refreshCompleted();
              },
            ),
          ),
          // Filtr va ko‘rinish tugmalari
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
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleWidth(12, context),
                    vertical: Responsive.scaleHeight(10, context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.mapPin, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
                      SizedBox(width: 6.sp),
                      Obx(() => Text(
                        funcController.userMe.value != null
                            ? funcController.userMe.value!.data!.district!.name ?? 'Viloyat'.tr
                            : 'Viloyat'.tr,
                        style: TextStyle(
                          color: AppColors.lightGray,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ],
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => showFilterDialog(context, funcController, apiController),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(12, context),
                      vertical: Responsive.scaleHeight(10, context),
                    ),
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
                  ),
                ),
                SizedBox(width: 10.sp),
                GestureDetector(
                  onTap: () {
                    funcController.isGridView.value = !funcController.isGridView.value;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(16, context),
                      vertical: Responsive.scaleHeight(10, context),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Obx(() => Icon(
                      funcController.isGridView.value ? LucideIcons.grid2x2 : LucideIcons.list,
                      color: AppColors.lightGray,
                      size: Responsive.scaleFont(20, context),
                    )),
                  ),
                ),
              ],
            ),
          ),
          // E‘lonlar ro‘yxati
          Expanded(
            child: RefreshComponent(
              refreshController: refreshController,
              scrollController: scrollController,
              color: AppColors.lightGray,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              enablePullUp: funcController.hasMore.value,
              child: Obx(() {
                final posts = funcController.mePosts;
                final isLoading = funcController.isLoading.value;

                if (isLoading && posts.isEmpty) {
                  // Skeleton ko‘rsatish
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: Responsive.scaleWidth(16, context),
                      right: Responsive.scaleWidth(16, context),
                      bottom: Responsive.scaleHeight(16, context),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: Responsive.scaleWidth(16, context),
                      mainAxisSpacing: Responsive.scaleHeight(16, context),
                      childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.6,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const SkeletonPostCard(),
                  );
                } else if (posts.isEmpty) {
                  // Bo‘sh sahifa
                  return SizedBox.expand(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.fileX,
                            size: 64.sp,
                            color: AppColors.lightGray.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.sp),
                          Text(
                            'Hozircha e‘lonlaringiz yo‘q'.tr,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: Responsive.scaleFont(18, context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.sp),
                          Text(
                            'Yangi e‘lon qo‘shish uchun quyidagi tugmani bosing'.tr,
                            style: TextStyle(
                              color: AppColors.lightGray,
                              fontSize: Responsive.scaleFont(14, context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.sp),
                          ElevatedButton(
                            onPressed: () => Get.toNamed('/add_post'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                              elevation: 0,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.scaleWidth(24, context),
                                vertical: Responsive.scaleHeight(12, context),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.lightBlue, AppColors.darkBlue],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.sp),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lightBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'E‘lon qo‘shish'.tr,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // E‘lonlar ro‘yxati
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: Responsive.scaleWidth(16, context),
                    right: Responsive.scaleWidth(16, context),
                    bottom: Responsive.scaleHeight(16, context),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    crossAxisSpacing: Responsive.scaleWidth(16, context),
                    mainAxisSpacing: Responsive.scaleHeight(16, context),
                    childAspectRatio: Responsive.screenWidth(context) < 300 ? 0.9 : 0.6,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(post: post);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}