import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/resumes_model.dart';
import '../controllers/create_resume_controller.dart';
import 'create_resume_screen.dart';

/// Foydalanuvchining rezyumelari.
class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key});

  @override
  MyResumesScreenState createState() => MyResumesScreenState();
}

class MyResumesScreenState extends State<MyResumesScreen> {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text('Mening Rezyumelarim'.tr)),
      body: SafeArea(
        child: Obx(() {
          if (funcController.isLoading.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.5),
                  const SizedBox(height: 16),
                  Text(
                    'Rezyumelar yuklanmoqda...'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          if (funcController.resumes.isEmpty) {
            return AppEmptyState(
              icon: LucideIcons.fileText,
              title: 'Rezyumelar mavjud emas'.tr,
              message:
                  'Yangi rezyume yaratish uchun yuqoridagi tugmani bosing'.tr,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await apiController.fetchMeResumes(page: 1, limit: 10);
            },
            color: theme.colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: funcController.resumes.length,
              itemBuilder: (context, index) {
                final resume = funcController.resumes[index];
                return AppReveal(
                  delay: AppReveal.step(index),
                  child: _ResumeCard(
                    resume: resume,
                    onOpen:
                        () => Get.to(() => CreateResumeScreen(resume: resume)),
                    onDelete: () => _confirmDelete(resume.id),
                  ),
                );
              },
            ),
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(
            label: 'Yangi rezyume yaratish'.tr,
            leading: const Icon(LucideIcons.plus),
            filled: true,
            onPressed: () => Get.to(() => CreateResumeScreen()),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int? resumeId) {
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.triangleAlert, color: AppColors.red, size: 21),
            const SizedBox(width: 10),
            Text('O‘chirish'.tr, style: theme.textTheme.titleLarge),
          ],
        ),
        content: Text(
          'Rostdan ham ushbu rezyumeni o\'chirmoqchimisiz?'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Bekor qilish'.tr),
          ),
          FilledButton(
            onPressed: () async {
              if (resumeId != null) {
                await apiController.deleteResume(resumeId);
                // `State.context` — shuning uchun State'ning `mounted` i.
                if (!mounted) return;
                Navigator.of(context).pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusControl),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: Text('O‘chirish'.tr),
          ),
        ],
      ),
    );
  }
}

/// Bitta rezyume kartasi.
class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.resume,
    required this.onOpen,
    required this.onDelete,
  });

  final ResumesData resume;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    final hasEducation =
        resume.education != null && resume.education!.isNotEmpty;
    final hasExperience =
        resume.experience != null && resume.experience!.isNotEmpty;
    final hasContent = resume.content != null && resume.content!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        size: 19,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resume.title ?? 'Noma’lum'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${'Yaratilgan'.tr}: ${resume.createdAt?.substring(0, 10) ?? '—'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        LucideIcons.trash2,
                        color: AppColors.red,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                if (hasContent) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      resume.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        height: 1.35,
                        color: muted,
                      ),
                    ),
                  ),
                ],
                if (hasEducation || hasExperience) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (hasEducation)
                        _Tag(
                          icon: LucideIcons.graduationCap,
                          text: '${resume.education!.length} ${'ta‘lim'.tr}',
                        ),
                      if (hasEducation && hasExperience)
                        const SizedBox(width: 8),
                      if (hasExperience)
                        _Tag(
                          icon: LucideIcons.briefcase,
                          text: '${resume.experience!.length} ${'tajriba'.tr}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rezyume kartasidagi kichik yorliq.
class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
