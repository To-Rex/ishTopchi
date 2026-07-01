import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/models/resumes_model.dart';
import '../../../core/utils/responsive.dart';
import 'create_resume_screen.dart';
import '../controllers/create_resume_controller.dart';

class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key});

  @override
  MyResumesScreenState createState() => MyResumesScreenState();
}

class MyResumesScreenState extends State<MyResumesScreen> {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    Get.put(CreateResumeController());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => apiController.fetchMeResumes(page: 1, limit: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textColor,
              size: Responsive.scaleFont(22, context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Mening Rezyumelarim'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: Responsive.scaleFont(18, context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (funcController.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.secondaryColor,
                          strokeWidth: 2.5,
                        ),
                        SizedBox(height: Responsive.scaleHeight(16, context)),
                        Text(
                          'Rezyumelar yuklanmoqda...'.tr,
                          style: TextStyle(
                            color: AppColors.textSecondaryColor,
                            fontSize: Responsive.scaleFont(14, context),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (funcController.resumes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scaleWidth(32, context),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: Responsive.scaleWidth(100, context),
                            height: Responsive.scaleWidth(100, context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryColor.withValues(alpha: 0.1),
                                  AppColors.secondaryColor.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.fileText,
                              size: Responsive.scaleFont(44, context),
                              color: AppColors.iconColor.withValues(alpha: 0.6),
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(20, context)),
                          Text(
                            'Rezyumelar mavjud emas'.tr,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: Responsive.scaleFont(18, context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(8, context)),
                          Text(
                            'Yangi rezyume yaratish uchun yuqoridagi tugmani bosing'
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(13, context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await apiController.fetchMeResumes(page: 1, limit: 10);
                  },
                  color: AppColors.secondaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(16, context),
                    ),
                    itemCount: funcController.resumes.length,
                    itemBuilder: (context, index) {
                      final resume = funcController.resumes[index];
                      return _buildResumeCard(context, resume, index);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.scaleWidth(16, context),
              Responsive.scaleHeight(8, context),
              Responsive.scaleWidth(16, context),
              Responsive.scaleHeight(12, context),
            ),
            child: GestureDetector(
              onTap: () => Get.to(() => CreateResumeScreen()),
              child: Container(
                width: double.infinity,
                height: Responsive.scaleHeight(54, context),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(10, context)),
                    Text(
                      'Yangi rezyume yaratish'.tr,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(15, context),
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildResumeCard(BuildContext context, ResumesData resume, int index) {
    final hasEducation = resume.education != null && resume.education!.isNotEmpty;
    final hasExperience = resume.experience != null && resume.experience!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: Responsive.scaleHeight(12, context),
      ),
      child: GestureDetector(
        onTap: () => Get.to(() => CreateResumeScreen(resume: resume)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.scaleWidth(16, context),
                  Responsive.scaleHeight(14, context),
                  Responsive.scaleWidth(16, context),
                  0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: Responsive.scaleWidth(44, context),
                      height: Responsive.scaleWidth(44, context),
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
                      ),
                      child: const Icon(
                        LucideIcons.fileText,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(12, context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.title ?? 'Noma’lum'.tr,
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: Responsive.scaleFont(15, context),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: Responsive.scaleHeight(3, context)),
                          Text(
                            '${'Yaratilgan'.tr}: ${resume.createdAt?.substring(0, 10) ?? '—'}',
                            style: TextStyle(
                              color: AppColors.textSecondaryColor,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(resume.id, index),
                      icon: Icon(
                        LucideIcons.trash2,
                        color: AppColors.red.withValues(alpha: 0.75),
                        size: Responsive.scaleFont(19, context),
                      ),
                      splashRadius: 20,
                      tooltip: 'O‘chirish'.tr,
                    ),
                  ],
                ),
              ),
              if (resume.content != null && resume.content!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.scaleWidth(16, context),
                    Responsive.scaleHeight(8, context),
                    Responsive.scaleWidth(16, context),
                    0,
                  ),
                  child: Text(
                    resume.content!,
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: Responsive.scaleFont(13, context),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (hasEducation || hasExperience)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.scaleWidth(16, context),
                    Responsive.scaleHeight(10, context),
                    Responsive.scaleWidth(16, context),
                    Responsive.scaleHeight(12, context),
                  ),
                  child: Wrap(
                    spacing: Responsive.scaleWidth(8, context),
                    runSpacing: Responsive.scaleHeight(6, context),
                    children: [
                      if (hasEducation)
                        _buildTag(
                          context,
                          icon: LucideIcons.graduationCap,
                          text: '${resume.education!.length} ${'ta‘lim'.tr}',
                        ),
                      if (hasExperience)
                        _buildTag(
                          context,
                          icon: LucideIcons.briefcase,
                          text: '${resume.experience!.length} ${'tajriba'.tr}',
                        ),
                    ],
                  ),
                ),
              if ((resume.content == null || resume.content!.isEmpty) &&
                  (!hasEducation && !hasExperience))
                SizedBox(height: Responsive.scaleHeight(12, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.scaleWidth(10, context),
        vertical: Responsive.scaleHeight(4, context),
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Responsive.scaleFont(13, context),
            color: AppColors.secondaryColor,
          ),
          SizedBox(width: Responsive.scaleWidth(5, context)),
          Text(
            text,
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontSize: Responsive.scaleFont(12, context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int? resumeId, int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              LucideIcons.triangleAlert,
              color: AppColors.red,
              size: Responsive.scaleFont(22, context),
            ),
            SizedBox(width: Responsive.scaleWidth(10, context)),
            Text(
              'O‘chirish'.tr,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Responsive.scaleFont(17, context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Rostdan ham ushbu rezyumeni o\'chirmoqchimisiz?'.tr,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: Responsive.scaleFont(14, context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scaleWidth(16, context),
                vertical: Responsive.scaleHeight(10, context),
              ),
            ),
            child: Text(
              'Bekor qilish'.tr,
              style: TextStyle(
                fontSize: Responsive.scaleFont(14, context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (resumeId != null) {
                await apiController.deleteResume(resumeId);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scaleWidth(20, context),
                vertical: Responsive.scaleHeight(10, context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'O‘chirish'.tr,
              style: TextStyle(
                fontSize: Responsive.scaleFont(14, context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
