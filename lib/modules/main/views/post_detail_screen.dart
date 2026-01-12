import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:ishtopchi/common/widgets/text_small.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:ishtopchi/modules/profile/views/create_resume_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailScreen extends StatefulWidget {
  final Data post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final ThemeController themeController = Get.find<ThemeController>();
  late final PostDetailController controller;
  late final AnimatedMapController mapController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostDetailController());
    mapController = AnimatedMapController(vsync: this);
    final latitude =
        widget.post.location?.latitude is String
            ? double.tryParse(widget.post.location!.latitude!)
            : widget.post.location?.latitude as double?;
    final longitude =
        widget.post.location?.longitude is String
            ? double.tryParse(widget.post.location!.longitude!)
            : widget.post.location?.longitude as double?;
    if (latitude != null && longitude != null) {
      controller.setInitialLocation(LatLng(latitude, longitude));
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    Get.delete<PostDetailController>();
    super.dispose();
  }

  void _showComplaintDialog(
    BuildContext context,
    ApiController apiController,
    int postId,
  ) {
    final TextEditingController complaintController = TextEditingController();

    Get.dialog(
      Obx(
        () => Dialog(
          backgroundColor: AppColors.backgroundColor,
          shadowColor: AppColors.shadowColor,
          surfaceTintColor: AppColors.backgroundColor,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSmall(
                    text: 'Shikoyat qilish'.tr,
                    color: AppColors.textColor,
                    fontSize: Responsive.scaleFont(18, context),
                    fontWeight: FontWeight.w800,
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  // Shikoyat matnini yozish
                  TextField(
                    controller: complaintController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: Responsive.scaleFont(14, context),
                      ),
                      hintText: 'Shikoyat matnini kiriting'.tr,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: Responsive.scaleFont(12, context),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        borderSide: BorderSide(color: AppColors.iconColor),
                      ),
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        borderSide: BorderSide(
                          color: AppColors.iconColor,
                          width: 1.5,
                        ),
                      ),
                      fillColor: AppColors.cardColor,
                    ),
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // Tugmalar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: TextSmall(
                          text: 'Bekor qilish'.tr,
                          color: AppColors.red,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingSmall),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.center,
                          fixedSize: Size(
                            Responsive.scaleWidth(100, context),
                            Responsive.scaleHeight(40, context),
                          ),
                        ),
                        onPressed: () async {
                          if (complaintController.text.trim().isEmpty) {
                            ShowToast.show(
                              'Xatolik'.tr,
                              'Iltimos, shikoyat matnini kiriting'.tr,
                              1,
                              1,
                            );
                            return;
                          }
                          Get.back();
                        },
                        child: TextSmall(
                          text: 'Yuborish'.tr,
                          color: AppColors.white,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginPromptDialog(BuildContext context) {
    Get.dialog(
      Obx(
        () => Dialog(
          backgroundColor: AppColors.backgroundColor,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    LucideIcons.lock,
                    size: Responsive.scaleFont(48, context),
                    color: AppColors.iconColor,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // Sarlavha
                  TextSmall(
                    text: 'Ro\'yxatdan o\'tish talab qilinadi'.tr,
                    color: AppColors.textColor,
                    maxLines: 2,
                    fontSize: Responsive.scaleFont(18, context),
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  // Tavsif
                  TextSmall(
                    text:
                        'Telefon raqamini ko\'rish uchun ro\'yxatdan o\'ting yoki hisobingizga kiring.'
                            .tr,
                    color: AppColors.textSecondaryColor,
                    maxLines: 100,
                    fontSize: Responsive.scaleFont(14, context),
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // Tugmalar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.paddingSmall,
                          ),
                        ),
                        child: TextSmall(
                          text: 'Bekor qilish'.tr,
                          color: AppColors.red,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingSmall),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.paddingSmall,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          Get.offNamed('/login');
                        },
                        child: TextSmall(
                          text: 'Kirish'.tr,
                          color: AppColors.textColor,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showApplicationDialog(
    BuildContext context,
    ApiController apiController,
    int postId,
  ) {
    final FuncController funcController = Get.find<FuncController>();
    final TextEditingController messageController = TextEditingController();
    final RxInt selectedResumeId = (-1).obs; // Tanlangan resume IDsi

    // Resumelarni olish
    apiController.fetchMeResumes(page: 1, limit: 100);

    Get.dialog(
      Obx(
        () => Dialog(
          backgroundColor: AppColors.backgroundColor,
          shadowColor: AppColors.shadowColor,
          surfaceTintColor: AppColors.backgroundColor,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sarlavha va tugma
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Murojaat qilish'.tr,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(18, context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(
                            LucideIcons.x,
                            color: AppColors.textSecondaryColor,
                            size: Responsive.scaleFont(20, context),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    // Resume tanlash
                    Obx(() {
                      if (funcController.isLoading.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.scaleHeight(40, context),
                            ),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.iconColor,
                                  strokeWidth: 2,
                                ),
                                SizedBox(height: AppDimensions.paddingSmall),
                                Text(
                                  'Rezyumelar yuklanmoqda...'.tr,
                                  style: TextStyle(
                                    color: AppColors.textSecondaryColor,
                                    fontSize: Responsive.scaleFont(14, context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (funcController.resumes.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(AppDimensions.paddingLarge),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.fileText,
                                size: Responsive.scaleFont(48, context),
                                color: AppColors.textSecondaryColor,
                              ),
                              SizedBox(height: AppDimensions.paddingMedium),
                              Text(
                                'Rezyumelar mavjud emas'.tr,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              Text(
                                'Murojaat qilish uchun rezyume yaratishingiz kerak'
                                    .tr,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor,
                                  fontSize: Responsive.scaleFont(13, context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: AppDimensions.paddingMedium),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Get.back();
                                  Get.to(CreateResumeScreen());
                                },
                                icon: Icon(
                                  LucideIcons.plus,
                                  size: Responsive.scaleFont(18, context),
                                ),
                                label: Text('Yangi rezyume qo‘shish'.tr),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: AppColors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingMedium,
                                    vertical: AppDimensions.paddingSmall,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        height: Responsive.scaleHeight(400, context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resume ro'yxati sarlavhasi
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.fileText,
                                  size: Responsive.scaleFont(16, context),
                                  color: AppColors.iconColor,
                                ),
                                SizedBox(
                                  width: Responsive.scaleWidth(6, context),
                                ),
                                Text(
                                  'Rezyume tanlang'.tr,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: Responsive.scaleFont(14, context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: Responsive.scaleWidth(4, context),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.scaleWidth(
                                      8,
                                      context,
                                    ),
                                    vertical: Responsive.scaleHeight(
                                      2,
                                      context,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withAlpha(50),
                                    borderRadius: BorderRadius.circular(
                                      Responsive.scaleWidth(10, context),
                                    ),
                                  ),
                                  child: Text(
                                    '${funcController.resumes.length}',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: Responsive.scaleFont(
                                        12,
                                        context,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppDimensions.paddingSmall),
                            // Resume kartalari
                            Expanded(
                              child: Obx(() {
                                // Trigger rebuild when selectedResumeId changes
                                selectedResumeId.value;
                                return ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: funcController.resumes.length,
                                  separatorBuilder:
                                      (context, index) => SizedBox(
                                        height: AppDimensions.paddingSmall,
                                      ),
                                  itemBuilder: (context, index) {
                                    final resume =
                                        funcController.resumes[index];
                                    final isSelected =
                                        selectedResumeId.value == resume.id;
                                    final educationCount =
                                        resume.education?.length ?? 0;
                                    final experienceCount =
                                        resume.experience?.length ?? 0;

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.primaryColor
                                                    .withAlpha(30)
                                                : AppColors.cardColor,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.cardRadius,
                                        ),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppColors.primaryColor
                                                  : AppColors.dividerColor,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          selectedResumeId.value = resume.id!;
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            AppDimensions.paddingMedium,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Header: title and selection indicator
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      resume.title ??
                                                          'Noma\'lum'.tr,
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textColor,
                                                        fontSize:
                                                            Responsive.scaleFont(
                                                              15,
                                                              context,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Container(
                                                      padding: EdgeInsets.all(
                                                        Responsive.scaleWidth(
                                                          4,
                                                          context,
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors
                                                                .primaryColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        LucideIcons.check,
                                                        color: AppColors.white,
                                                        size:
                                                            Responsive.scaleFont(
                                                              14,
                                                              context,
                                                            ),
                                                      ),
                                                    )
                                                  else
                                                    Container(
                                                      width:
                                                          Responsive.scaleWidth(
                                                            22,
                                                            context,
                                                          ),
                                                      height:
                                                          Responsive.scaleWidth(
                                                            22,
                                                            context,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color:
                                                              AppColors
                                                                  .iconColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              if (resume.content != null &&
                                                  resume.content!.isNotEmpty)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    top:
                                                        AppDimensions
                                                            .paddingSmall,
                                                  ),
                                                  child: Text(
                                                    resume.content!,
                                                    style: TextStyle(
                                                      color:
                                                          AppColors
                                                              .textSecondaryColor,
                                                      fontSize:
                                                          Responsive.scaleFont(
                                                            12,
                                                            context,
                                                          ),
                                                      height: 1.4,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              // Stats row
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top:
                                                      AppDimensions
                                                          .paddingSmall,
                                                ),
                                                child: Row(
                                                  children: [
                                                    if (educationCount > 0) ...[
                                                      Icon(
                                                        LucideIcons
                                                            .graduationCap,
                                                        size:
                                                            Responsive.scaleFont(
                                                              12,
                                                              context,
                                                            ),
                                                        color:
                                                            AppColors.iconColor,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            Responsive.scaleWidth(
                                                              4,
                                                              context,
                                                            ),
                                                      ),
                                                      Text(
                                                        '$educationCount ${'ta\'lim'.tr}',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textSecondaryColor,
                                                          fontSize:
                                                              Responsive.scaleFont(
                                                                11,
                                                                context,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                    if (educationCount > 0 &&
                                                        experienceCount > 0)
                                                      SizedBox(
                                                        width:
                                                            Responsive.scaleWidth(
                                                              12,
                                                              context,
                                                            ),
                                                      ),
                                                    if (experienceCount >
                                                        0) ...[
                                                      Icon(
                                                        LucideIcons.briefcase,
                                                        size:
                                                            Responsive.scaleFont(
                                                              12,
                                                              context,
                                                            ),
                                                        color:
                                                            AppColors.iconColor,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            Responsive.scaleWidth(
                                                              4,
                                                              context,
                                                            ),
                                                      ),
                                                      Text(
                                                        '$experienceCount ${'tajriba'.tr}',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textSecondaryColor,
                                                          fontSize:
                                                              Responsive.scaleFont(
                                                                11,
                                                                context,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                    Spacer(),
                                                    if (resume.createdAt !=
                                                        null)
                                                      Text(
                                                        _formatDate(
                                                          resume.createdAt!,
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              AppColors
                                                                  .textSecondaryColor,
                                                          fontSize:
                                                              Responsive.scaleFont(
                                                                10,
                                                                context,
                                                              ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: AppDimensions.paddingSmall),
                    // Xabar yozish
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                      child: TextField(
                        controller: messageController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Xabar'.tr,
                          labelStyle: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: Responsive.scaleFont(14, context),
                          ),
                          hintText: 'Murojaat matnini kiriting...'.tr,
                          hintStyle: TextStyle(
                            color: AppColors.textSecondaryColor.withAlpha(150),
                            fontSize: Responsive.scaleFont(12, context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // Tugmalar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMedium,
                              vertical: AppDimensions.paddingSmall,
                            ),
                          ),
                          child: Text(
                            'Bekor qilish'.tr,
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(14, context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: AppDimensions.paddingSmall),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingLarge,
                              vertical: AppDimensions.paddingSmall,
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (selectedResumeId.value == -1) {
                              ShowToast.show(
                                'Xatolik'.tr,
                                'Iltimos, rezyume tanlang'.tr,
                                1,
                                1,
                              );
                              return;
                            }
                            if (messageController.text.trim().isEmpty) {
                              ShowToast.show(
                                'Xatolik'.tr,
                                'Iltimos, xabar kiriting'.tr,
                                1,
                                1,
                              );
                              return;
                            }
                            Get.back();
                            await apiController.createApplication(
                              postId,
                              messageController.text.trim(),
                              selectedResumeId.value,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.send,
                                size: Responsive.scaleFont(16, context),
                              ),
                              SizedBox(
                                width: Responsive.scaleWidth(6, context),
                              ),
                              Text(
                                'Yuborish'.tr,
                                style: TextStyle(
                                  fontSize: Responsive.scaleFont(14, context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Bugun';
      } else if (difference.inDays == 1) {
        return 'Kecha';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} kun oldin';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks hafta oldin';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _maskPhoneNumber(String phone) {
    // Uzbek phone format: +998 XX XXX XX XX
    if (phone.startsWith('+998')) {
      return '+998 ** *** ** **';
    } else {
      // Fallback for other formats
      return phone.replaceAll(RegExp(r'\d'), '*');
    }
  }

  void _moveMap(LatLng point, double zoom) => mapController.animateTo(
    dest: point,
    zoom: zoom,
    duration: const Duration(milliseconds: 900),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textColor,
              size: Responsive.scaleFont(22, context),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'E’lon tafsilotlari'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: Responsive.scaleFont(18, context),
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            Obx(() {
              final isFavorite = funcController.wishList.any(
                (w) => w.id == widget.post.id,
              );
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      isFavorite ? AppColors.red : AppColors.textSecondaryColor,
                  size: Responsive.scaleFont(22, context),
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await apiController.removeFromWishlist(
                      widget.post.id!.toInt(),
                    );
                  } else {
                    await apiController.addToWishlist(widget.post.id!.toInt());
                  }
                },
              );
            }),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 200),
                childAnimationBuilder:
                    (widget) => SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(child: widget),
                    ),
                children: [
                  // 1. Surat
                  if (widget.post.pictureUrl != null &&
                      widget.post.pictureUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: Responsive.scaleHeight(200, context),
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl:
                              widget.post.pictureUrl!.startsWith('http')
                                  ? widget.post.pictureUrl!
                                  : 'https://ishtopchi.uz${widget.post.pictureUrl}',
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.iconColor,
                                  strokeWidth: 2,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                height: Responsive.scaleHeight(200, context),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    LucideIcons.imageOff,
                                    size: Responsive.scaleFont(48, context),
                                    color: AppColors.textSecondaryColor,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // 2. Sarlavha
                  Text(
                    widget.post.title ?? 'Noma’lum'.tr,
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(22, context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  // 3. ish turi
                  if (widget.post.jobType != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.briefcaseBusiness,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.iconColor,
                        ),
                        SizedBox(width: Responsive.scaleWidth(6, context)),
                        Text(
                          widget.post.jobType == 'FULL_TIME'
                              ? 'To‘liq ish kuni'.tr
                              : widget.post.jobType == 'TEMPORARY'
                              ? 'Vaqtinchalik ish'.tr
                              : widget.post.jobType == 'REMOTE'
                              ? 'Masofaviy ish'.tr
                              : widget.post.jobType == 'DAILY'
                              ? 'Kunlik ish'.tr
                              : widget.post.jobType == 'PROJECT_BASED'
                              ? 'Loyihaviy ish'.tr
                              : widget.post.jobType == 'INTERNSHIP'
                              ? 'Amaliyot'.tr
                              : 'Noma’lum'.tr,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(13, context),
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  if (widget.post.jobType != null)
                    SizedBox(height: AppDimensions.paddingSmall),
                  // 3. ish turi
                  if (widget.post.employmentType != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.briefcase,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.iconColor,
                        ),
                        SizedBox(width: Responsive.scaleWidth(6, context)),
                        Text(
                          widget.post.employmentType == 'FULL_TIME'
                              ? 'To‘liq ish kuni'.tr
                              : widget.post.employmentType == 'PART_TIME'
                              ? 'Yarim stavka'.tr
                              : widget.post.employmentType == 'SHIFT_BASED'
                              ? 'Smenali ish'.tr
                              : widget.post.employmentType == 'FLEXIBLE'
                              ? 'Moslashuvchan ish'.tr
                              : widget.post.employmentType == 'REGULAR_SCHEDULE'
                              ? 'Doimiy jadval'.tr
                              : 'Noma’lum'.tr,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(13, context),
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  if (widget.post.employmentType != null)
                    SizedBox(height: AppDimensions.paddingSmall),
                  // 3. Joylashtirilgan vaqt
                  if (widget.post.createdAt != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.textSecondaryColor,
                        ),
                        SizedBox(width: Responsive.scaleWidth(6, context)),
                        Text(
                          '${'Joylashtirilgan'.tr}: ${widget.post.createdAt!.substring(0, 10)}',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(13, context),
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  // 4. Ish haqi
                  Row(
                    children: [
                      Icon(
                        LucideIcons.wallet,
                        size: Responsive.scaleFont(16, context),
                        color: AppColors.iconColor,
                      ),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Text(
                        '${widget.post.salaryFrom ?? 'Noma’lum'.tr} - ${widget.post.salaryTo ?? 'Noma’lum'.tr} UZS',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(14, context),
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  // 5. Joylashuv
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: Responsive.scaleFont(16, context),
                        color: AppColors.iconColor,
                      ),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Expanded(
                        child: Text(
                          widget.post.district?.name ??
                              widget.post.location?.title ??
                              'Noma’lum tuman'.tr,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(14, context),
                            color: AppColors.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // 6. Tavsif
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.post.content ?? 'Tavsif yo‘q'.tr,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(15, context),
                        color: AppColors.textSecondaryColor,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // 7. Bog‘lanish uchun
                  Text(
                    'Bog‘lanish uchun'.tr,
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(15, context),
                      color: AppColors.iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  if (widget.post.phoneNumber != null)
                    GestureDetector(
                      onTap: () async {
                        if (funcController.globalToken.value.isNotEmpty) {
                          final url = Uri.parse(
                            'tel:${widget.post.phoneNumber}',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            Get.snackbar(
                              'Xato'.tr,
                              'Qo‘ng‘iroq qilib bo‘lmadi'.tr,
                            );
                          }
                        } else {
                          _showLoginPromptDialog(context);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.phone,
                            size: Responsive.scaleFont(16, context),
                            color: AppColors.iconColor,
                          ),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text(
                            funcController.globalToken.value.isNotEmpty
                                ? widget.post.phoneNumber!
                                : _maskPhoneNumber(widget.post.phoneNumber!),
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(13, context),
                              color: AppColors.textColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.post.email != null) ...[
                    SizedBox(height: AppDimensions.paddingSmall),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse('mailto:${widget.post.email}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          Get.snackbar('Xato'.tr, 'Email yuborib bo‘lmadi'.tr);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.mail,
                            size: Responsive.scaleFont(16, context),
                            color: AppColors.iconColor,
                          ),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text(
                            widget.post.email!,
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(13, context),
                              color: AppColors.textColor,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: AppDimensions.paddingMedium),
                  AnimationConfiguration.staggeredList(
                    position: 10, // Mos index
                    duration: const Duration(milliseconds: 200),
                    child: SlideAnimation(
                      verticalOffset: 30.0,
                      child: FadeInAnimation(
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingSmall,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                              color: AppColors.primaryColor,
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  () => _showApplicationDialog(
                                    context,
                                    apiController,
                                    widget.post.id!,
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.cardRadius,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Murojaat qilish'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // 8. Foydalanuvchi ismi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: Responsive.scaleWidth(20, context),
                        backgroundImage:
                            widget.post.user?.profilePicture != null
                                ? NetworkImage(
                                  funcController.getProfileUrl(
                                    widget.post.user!.profilePicture,
                                  ),
                                )
                                : null,
                        backgroundColor: AppColors.cardColor,
                        child:
                            widget.post.user?.profilePicture == null
                                ? Icon(
                                  LucideIcons.user,
                                  size: Responsive.scaleFont(20, context),
                                  color: AppColors.textSecondaryColor,
                                )
                                : null,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Expanded(
                        child: Text(
                          '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}'
                              .trim(),
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(15, context),
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  // 9. Xarita
                  Obx(
                    () => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: Responsive.scaleHeight(300, context),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: mapController.mapController,
                              options: MapOptions(
                                initialCenter:
                                    controller.selectedLocation.value ??
                                    LatLng(41.3111, 69.2401),
                                initialZoom: controller.currentZoom.value,
                                onMapReady: () {
                                  controller.isMapReady.value = true;
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: const ['a', 'b', 'c'],
                                  userAgentPackageName: 'torex.top.ishtopchi',
                                ),
                                Obx(
                                  () => MarkerLayer(
                                    markers: [
                                      if (controller.currentLocation.value !=
                                          null)
                                        Marker(
                                          width: 38.0,
                                          height: 38.0,
                                          point:
                                              controller.currentLocation.value!,
                                          child: const Icon(
                                            LucideIcons.locateFixed,
                                            color: Colors.blue,
                                            size: 18.0,
                                          ),
                                        ),
                                      Marker(
                                        width: 38.0,
                                        height: 38.0,
                                        point:
                                            controller.selectedLocation.value ??
                                            LatLng(41.3111, 69.2401),
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 28.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: AppDimensions.paddingSmall,
                              top: AppDimensions.paddingSmall,
                              child: Column(
                                children: [
                                  IconButton(
                                    splashColor: AppColors.cardColor,
                                    color: AppColors.cardColor,
                                    splashRadius: 20,
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.cardRadius,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(
                                      LucideIcons.plus,
                                      color: AppColors.textSecondaryColor,
                                      size: Responsive.scaleFont(18, context),
                                    ),
                                    onPressed:
                                        () => controller.zoomIn(_moveMap),
                                  ),
                                  SizedBox(height: AppDimensions.paddingSmall),
                                  IconButton(
                                    splashColor: AppColors.cardColor,
                                    color: AppColors.cardColor,
                                    splashRadius: 20,
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.cardRadius,
                                        ),
                                      ),
                                    ),
                                    icon: Icon(
                                      LucideIcons.minus,
                                      color: AppColors.textSecondaryColor,
                                      size: Responsive.scaleFont(18, context),
                                    ),
                                    onPressed:
                                        () => controller.zoomOut(_moveMap),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: AppDimensions.paddingSmall,
                              bottom: AppDimensions.paddingSmall,
                              child: IconButton(
                                splashColor: AppColors.cardColor,
                                color: AppColors.cardColor,
                                splashRadius: 20,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                ),
                                icon: Icon(
                                  LucideIcons.locate,
                                  color: Colors.blue,
                                  size: Responsive.scaleFont(20, context),
                                ),
                                tooltip: 'Joriy joylashuvni aniqlash'.tr,
                                onPressed:
                                    () =>
                                        controller.getCurrentLocation(_moveMap),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingLarge),
                  // 10. ID, Ko‘rishlar, Shikoyat
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.hash,
                              size: Responsive.scaleFont(16, context),
                              color: AppColors.textSecondaryColor,
                            ),
                            SizedBox(width: Responsive.scaleWidth(6, context)),
                            Text(
                              'ID: ${widget.post.id ?? 'Noma’lum'.tr}',
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(13, context),
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.eye,
                              size: Responsive.scaleFont(16, context),
                              color: AppColors.textSecondaryColor,
                            ),
                            SizedBox(width: Responsive.scaleWidth(6, context)),
                            Text(
                              '${widget.post.views ?? 0} ko‘rish'.tr,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(13, context),
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.paddingSmall),
                        GestureDetector(
                          onTap:
                              () => _showComplaintDialog(
                                context,
                                apiController,
                                widget.post.id!,
                              ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.circleAlert,
                                size: Responsive.scaleFont(16, context),
                                color: AppColors.red,
                              ),
                              SizedBox(
                                width: Responsive.scaleWidth(6, context),
                              ),
                              Text(
                                'Shikoyat qilish'.tr,
                                style: TextStyle(
                                  fontSize: Responsive.scaleFont(13, context),
                                  color: AppColors.red,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
