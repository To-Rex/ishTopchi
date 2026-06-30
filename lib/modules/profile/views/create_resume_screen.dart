import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/models/resumes_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/create_resume_controller.dart';

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
    final ThemeController themeController = Get.find<ThemeController>();
    controller.loadResumeData(widget.resume);

    if (controller.titleController.value != titleController.text) {
      titleController.text = controller.titleController.value;
    }
    if (controller.contentController.value != contentController.text) {
      contentController.text = controller.contentController.value;
    }

    return Obx(
      () => Scaffold(
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
            'Rezyume yaratish'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: Responsive.scaleFont(18, context),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (controller.isEditing.value)
              Padding(
                padding: EdgeInsets.only(
                  right: Responsive.scaleWidth(12, context),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleWidth(10, context),
                    vertical: Responsive.scaleHeight(4, context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Tahrirlash'.tr,
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: Responsive.scaleFont(12, context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleWidth(16, context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Responsive.scaleHeight(8, context)),
              _buildSectionLabel(context, 'Asosiy ma’lumotlar'.tr),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              _buildTextField(
                context,
                label: 'Sarlavha'.tr,
                hint: 'Rezyume sarlavhasini kiriting'.tr,
                controller: titleController,
                icon: LucideIcons.fileText,
                onChanged: (value) => controller.titleController.value = value,
              ),
              SizedBox(height: Responsive.scaleHeight(14, context)),
              _buildTextField(
                context,
                label: 'Tavsif'.tr,
                hint: 'O‘zingiz haqingizda qisqacha...'.tr,
                controller: contentController,
                maxLines: 4,
                icon: LucideIcons.alignLeft,
                onChanged: (value) => controller.contentController.value = value,
              ),
              SizedBox(height: Responsive.scaleHeight(14, context)),
              _buildSectionLabel(context, 'Fayl'.tr),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              _buildFilePicker(context, controller),
              SizedBox(height: Responsive.scaleHeight(22, context)),
              _buildSectionLabel(context, 'Ta’lim'.tr),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              Obx(
                () => Column(
                  children: controller.educationList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final education = entry.value;
                    return _buildEducationField(
                      context, controller, index, education,
                    );
                  }).toList(),
                ),
              ),
              _buildAddButton(
                context,
                label: '+ Ta’lim qo‘shish'.tr,
                onTap: () => controller.addEducation(),
              ),
              SizedBox(height: Responsive.scaleHeight(22, context)),
              _buildSectionLabel(context, 'Tajriba'.tr),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              Obx(
                () => Column(
                  children: controller.experienceList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final experience = entry.value;
                    return _buildExperienceField(
                      context, controller, index, experience,
                    );
                  }).toList(),
                ),
              ),
              _buildAddButton(
                context,
                label: '+ Tajriba qo‘shish'.tr,
                onTap: () => controller.addExperience(),
              ),
              SizedBox(height: Responsive.scaleHeight(32, context)),
              Obx(
                () => Center(
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: AppColors.secondaryColor)
                      : GestureDetector(
                          onTap: controller.saveResume,
                          child: Container(
                            width: double.infinity,
                            height: Responsive.scaleHeight(52, context),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryColor,
                                  AppColors.secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  controller.isEditing.value
                                      ? LucideIcons.pencil
                                      : LucideIcons.save,
                                  color: AppColors.white,
                                  size: Responsive.scaleFont(18, context),
                                ),
                                SizedBox(width: Responsive.scaleWidth(8, context)),
                                Text(
                                  controller.isEditing.value
                                      ? 'Yangilash'.tr
                                      : 'Saqlash'.tr,
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: Responsive.scaleFont(15, context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: Responsive.scaleHeight(40, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: Responsive.scaleHeight(18, context),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: Responsive.scaleWidth(8, context)),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    String? hint,
    required TextEditingController controller,
    int maxLines = 1,
    IconData? icon,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: Responsive.scaleHeight(6, context)),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: Responsive.scaleFont(13, context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextField(
          maxLines: maxLines,
          controller: controller,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(14, context),
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondaryColor.withValues(alpha: 0.5),
              fontSize: Responsive.scaleFont(13, context),
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.secondaryColor, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.secondaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: maxLines > 1 ? 14 : 12,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFilePicker(
    BuildContext context,
    CreateResumeController controller,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: controller.pickFile,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleWidth(16, context),
            vertical: Responsive.scaleHeight(14, context),
          ),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.dividerColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.scaleWidth(42, context),
                height: Responsive.scaleWidth(42, context),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  controller.selectedFile.value != null ||
                          (widget.resume?.fileUrl != null &&
                              widget.resume!.fileUrl!.isNotEmpty)
                      ? LucideIcons.fileCheck
                      : LucideIcons.paperclip,
                  color: AppColors.secondaryColor,
                  size: Responsive.scaleFont(20, context),
                ),
              ),
              SizedBox(width: Responsive.scaleWidth(12, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fayl biriktirish'.tr,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: Responsive.scaleFont(14, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(2, context)),
                    Text(
                      controller.selectedFile.value == null
                          ? widget.resume?.fileUrl != null &&
                                  widget.resume!.fileUrl!.isNotEmpty
                              ? widget.resume!.fileUrl!.split('/').last
                              : 'PDF yoki rasm tanlang'.tr
                          : controller.selectedFile.value!.path.split('/').last,
                      style: TextStyle(
                        color: AppColors.textSecondaryColor,
                        fontSize: Responsive.scaleFont(12, context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.upload,
                color: AppColors.secondaryColor,
                size: Responsive.scaleFont(18, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: Responsive.scaleHeight(12, context)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context)),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.dividerColor.withValues(alpha: 0.8),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.plus,
                color: AppColors.secondaryColor,
                size: Responsive.scaleFont(18, context),
              ),
              SizedBox(width: Responsive.scaleWidth(6, context)),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontSize: Responsive.scaleFont(14, context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEducationField(
    BuildContext context,
    CreateResumeController controller,
    int index,
    Education education,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.scaleWidth(14, context),
                Responsive.scaleHeight(12, context),
                Responsive.scaleWidth(8, context),
                0,
              ),
              child: Row(
                children: [
                  Container(
                    width: Responsive.scaleWidth(28, context),
                    height: Responsive.scaleWidth(28, context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: Responsive.scaleFont(12, context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.scaleWidth(10, context)),
                  Text(
                    'Ta’lim ${index + 1}'.tr,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      color: AppColors.red.withValues(alpha: 0.8),
                      size: Responsive.scaleFont(18, context),
                    ),
                    onPressed: () => controller.removeEducation(index),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColors.dividerColor.withValues(alpha: 0.5),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.scaleWidth(14, context)),
              child: Column(
                children: [
                  _buildTextField(
                    context,
                    label: 'Daraja (masalan, Bakalavr)'.tr,
                    controller: TextEditingController(text: education.degree)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: education.degree?.length ?? 0),
                      ),
                    onChanged: (value) => education.degree = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Yo‘nalish'.tr,
                    controller: TextEditingController(text: education.field)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: education.field?.length ?? 0),
                      ),
                    onChanged: (value) => education.field = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Muassasa'.tr,
                    controller: TextEditingController(text: education.institution)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: education.institution?.length ?? 0),
                      ),
                    onChanged: (value) => education.institution = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Davri (masalan, 2018-2022)'.tr,
                    controller: TextEditingController(text: education.period)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: education.period?.length ?? 0),
                      ),
                    onChanged: (value) => education.period = value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceField(
    BuildContext context,
    CreateResumeController controller,
    int index,
    Experience experience,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.scaleWidth(14, context),
                Responsive.scaleHeight(12, context),
                Responsive.scaleWidth(8, context),
                0,
              ),
              child: Row(
                children: [
                  Container(
                    width: Responsive.scaleWidth(28, context),
                    height: Responsive.scaleWidth(28, context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: Responsive.scaleFont(12, context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.scaleWidth(10, context)),
                  Text(
                    'Tajriba ${index + 1}'.tr,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      color: AppColors.red.withValues(alpha: 0.8),
                      size: Responsive.scaleFont(18, context),
                    ),
                    onPressed: () => controller.removeExperience(index),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(
              color: AppColors.dividerColor.withValues(alpha: 0.5),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.scaleWidth(14, context)),
              child: Column(
                children: [
                  _buildTextField(
                    context,
                    label: 'Lavozim'.tr,
                    controller: TextEditingController(text: experience.position)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: experience.position?.length ?? 0),
                      ),
                    onChanged: (value) => experience.position = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Kompaniya'.tr,
                    controller: TextEditingController(text: experience.company)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: experience.company?.length ?? 0),
                      ),
                    onChanged: (value) => experience.company = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Davri (masalan, 2022-Hozir)'.tr,
                    controller: TextEditingController(text: experience.period)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: experience.period?.length ?? 0),
                      ),
                    onChanged: (value) => experience.period = value,
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                  _buildTextField(
                    context,
                    label: 'Tavsif'.tr,
                    controller: TextEditingController(text: experience.description)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: experience.description?.length ?? 0),
                      ),
                    maxLines: 3,
                    onChanged: (value) => experience.description = value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
