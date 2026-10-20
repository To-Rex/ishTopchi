import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_theme.dart';
import '../../../core/models/resumes_model.dart';
import '../controllers/create_resume_controller.dart';

/// Rezyume yaratish va tahrirlash.
///
/// Maydonlarning bezagi mavzudan keladi — avval har biri uchun alohida
/// `InputDecoration` yozilgan edi.
class CreateResumeScreen extends StatefulWidget {
  final ResumesData? resume;

  const CreateResumeScreen({super.key, this.resume});

  @override
  State<CreateResumeScreen> createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends State<CreateResumeScreen> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateResumeController());
    controller.loadResumeData(widget.resume);
    if (controller.titleController.value != titleController.text) {
      titleController.text = controller.titleController.value;
    }
    if (controller.contentController.value != contentController.text) {
      contentController.text = controller.contentController.value;
    }

    return AppScreen(
      title: 'Rezyume yaratish'.tr,
      actions: [
        Obx(
          () =>
              controller.isEditing.value
                  ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(child: _EditingBadge()),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionLabel(text: 'Asosiy ma’lumotlar'.tr),
            AppReveal(
              child: _buildField(
                label: 'Sarlavha'.tr,
                hint: 'Rezyume sarlavhasini kiriting'.tr,
                controller: titleController,
                icon: LucideIcons.fileText,
                onChanged: (value) => controller.titleController.value = value,
              ),
            ),
            const SizedBox(height: 12),
            AppReveal(
              delay: AppReveal.step(1),
              child: _buildField(
                label: 'Tavsif'.tr,
                hint: 'O‘zingiz haqingizda qisqacha...'.tr,
                controller: contentController,
                maxLines: 4,
                icon: LucideIcons.alignLeft,
                onChanged:
                    (value) => controller.contentController.value = value,
              ),
            ),
            const SizedBox(height: 18),
            AppSectionLabel(text: 'Fayl'.tr),
            AppReveal(
              delay: AppReveal.step(2),
              child: _buildFilePicker(controller),
            ),
            const SizedBox(height: 18),
            AppSectionLabel(text: 'Ta’lim'.tr),
            Obx(
              () => Column(
                children:
                    controller.educationList.asMap().entries.map((entry) {
                      return _EntryBlock(
                        title: '${'Ta’lim'.tr} ${entry.key + 1}',
                        onRemove: () => controller.removeEducation(entry.key),
                        children: [
                          _buildField(
                            label: 'Daraja (masalan, Bakalavr)'.tr,
                            controller: TextEditingController(
                              text: entry.value.degree,
                            ),
                            onChanged: (value) => entry.value.degree = value,
                          ),
                          _buildField(
                            label: 'Yo‘nalish'.tr,
                            controller: TextEditingController(
                              text: entry.value.field,
                            ),
                            onChanged: (value) => entry.value.field = value,
                          ),
                          _buildField(
                            label: 'Muassasa'.tr,
                            controller: TextEditingController(
                              text: entry.value.institution,
                            ),
                            onChanged:
                                (value) => entry.value.institution = value,
                          ),
                          _buildField(
                            label: 'Davri (masalan, 2018-2022)'.tr,
                            controller: TextEditingController(
                              text: entry.value.period,
                            ),
                            onChanged: (value) => entry.value.period = value,
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            _AddButton(
              label: '+ Ta’lim qo‘shish'.tr,
              onTap: () => controller.addEducation(),
            ),
            const SizedBox(height: 18),
            AppSectionLabel(text: 'Tajriba'.tr),
            Obx(
              () => Column(
                children:
                    controller.experienceList.asMap().entries.map((entry) {
                      return _EntryBlock(
                        title: '${'Tajriba'.tr} ${entry.key + 1}',
                        onRemove: () => controller.removeExperience(entry.key),
                        children: [
                          _buildField(
                            label: 'Lavozim'.tr,
                            controller: TextEditingController(
                              text: entry.value.position,
                            ),
                            onChanged: (value) => entry.value.position = value,
                          ),
                          _buildField(
                            label: 'Kompaniya'.tr,
                            controller: TextEditingController(
                              text: entry.value.company,
                            ),
                            onChanged: (value) => entry.value.company = value,
                          ),
                          _buildField(
                            label: 'Davri (masalan, 2022-Hozir)'.tr,
                            controller: TextEditingController(
                              text: entry.value.period,
                            ),
                            onChanged: (value) => entry.value.period = value,
                          ),
                          _buildField(
                            label: 'Tavsif'.tr,
                            maxLines: 3,
                            controller: TextEditingController(
                              text: entry.value.description,
                            ),
                            onChanged:
                                (value) => entry.value.description = value,
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            _AddButton(
              label: '+ Tajriba qo‘shish'.tr,
              onTap: () => controller.addExperience(),
            ),
            const SizedBox(height: 28),
            Obx(
              () => AppButton(
                label:
                    controller.isEditing.value ? 'Yangilash'.tr : 'Saqlash'.tr,
                leading: Icon(
                  controller.isEditing.value
                      ? LucideIcons.pencil
                      : LucideIcons.save,
                ),
                filled: true,
                loading: controller.isLoading.value,
                onPressed:
                    controller.isLoading.value ? null : controller.saveResume,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon, size: 18),
        ),
      ),
    );
  }

  /// Fayl biriktirish.
  Widget _buildFilePicker(CreateResumeController controller) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return Obx(() {
      final hasFile =
          controller.selectedFile.value != null ||
          (widget.resume?.fileUrl != null &&
              widget.resume!.fileUrl!.isNotEmpty);

      final fileName =
          controller.selectedFile.value == null
              ? (widget.resume?.fileUrl != null &&
                      widget.resume!.fileUrl!.isNotEmpty
                  ? widget.resume!.fileUrl!.split('/').last
                  : 'PDF yoki rasm tanlang'.tr)
              : controller.selectedFile.value!.path.split('/').last;

      return Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.pickFile,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color:
                    hasFile
                        ? colors.primary.withValues(alpha: 0.35)
                        : colors.onSurface.withValues(alpha: 0.08),
                width: hasFile ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasFile ? LucideIcons.fileCheck : LucideIcons.paperclip,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fayl biriktirish'.tr,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                          color: colors.onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  LucideIcons.upload,
                  size: 18,
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Sarlavhadagi "tahrirlash" yorligʻi.
class _EditingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Tahrirlash'.tr,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: colors.primary,
        ),
      ),
    );
  }
}

/// Taʼlim yoki tajriba bloki.
class _EntryBlock extends StatelessWidget {
  const _EntryBlock({
    required this.title,
    required this.onRemove,
    required this.children,
  });

  final String title;
  final VoidCallback onRemove;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
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
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              IconButton(
                onPressed: onRemove,
                icon: Icon(LucideIcons.trash2, size: 18, color: colors.error),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

/// "Qoʻshish" tugmasi — konturli, punktir taassurotini beruvchi.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusControl);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 14,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
