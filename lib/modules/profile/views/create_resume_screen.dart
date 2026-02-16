import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = Get.find<CreateResumeController>();
    // Update controllers when controller values change
    if (controller.titleController.value != titleController.text) {
      titleController.text = controller.titleController.value;
    }
    if (controller.contentController.value != contentController.text) {
      contentController.text = controller.contentController.value;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kontrollerni yaratish yoki topish
    final controller = Get.put(CreateResumeController());
    final ThemeController themeController = Get.find<ThemeController>();
    controller.loadResumeData(widget.resume); // Resume ma'lumotlarini yuklash

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textColor,
              size: Responsive.scaleFont(25, context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Rezyume yaratish'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: Responsive.scaleFont(20, context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sarlavha
                _buildTextField(
                  context,
                  label: 'Sarlavha'.tr,
                  controller: titleController,
                  onChanged:
                      (value) => controller.titleController.value = value,
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // Tavsif
                _buildTextField(
                  context,
                  label: 'Tavsif'.tr,
                  controller: contentController,
                  maxLines: 4,
                  onChanged:
                      (value) => controller.contentController.value = value,
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // Fayl tanlash
                _buildFilePicker(context, controller),
                SizedBox(height: AppDimensions.paddingMedium),
                // Ta'lim bo'limi
                _buildSectionTitle(
                  context,
                  'Ta’lim'.tr,
                  () => controller.addEducation(),
                ),
                Obx(
                  () => Column(
                    children:
                        controller.educationList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final education = entry.value;
                          return _buildEducationField(
                            context,
                            controller,
                            index,
                            education,
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // Tajriba bo'limi
                _buildSectionTitle(
                  context,
                  'Tajriba'.tr,
                  () => controller.addExperience(),
                ),
                Obx(
                  () => Column(
                    children:
                        controller.experienceList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final experience = entry.value;
                          return _buildExperienceField(
                            context,
                            controller,
                            index,
                            experience,
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingLarge),
                // Saqlash/Yangilash tugmasi
                Obx(
                  () => Center(
                    child:
                        controller.isLoading.value
                            ? CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            )
                            : ElevatedButton(
                              onPressed: controller.saveResume,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                fixedSize: Size(
                                  double.infinity,
                                  Responsive.scaleHeight(48, context),
                                ),
                                minimumSize: Size(
                                  double.infinity,
                                  Responsive.scaleHeight(48, context),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingLarge,
                                  vertical: AppDimensions.paddingSmall,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.cardRadius,
                                  ),
                                ),
                                elevation: 5,
                              ),
                              child: Text(
                                controller.isEditing.value
                                    ? 'Yangilash'.tr
                                    : 'Saqlash'.tr,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: Responsive.scaleFont(14, context),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textSecondaryColor,
          fontSize: Responsive.scaleFont(14, context),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
      ),
      onChanged: onChanged,
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
          padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.attach_file,
                color: AppColors.primaryColor,
                size: Responsive.scaleFont(20, context),
              ),
              SizedBox(width: Responsive.scaleWidth(10, context)),
              Expanded(
                child: Text(
                  controller.selectedFile.value == null
                      ? widget.resume?.fileUrl != null
                          ? widget.resume!.fileUrl!.split('/').last
                          : 'Fayl tanlash'.tr
                      : controller.selectedFile.value!.path.split('/').last,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    VoidCallback onAdd,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_circle,
            color: AppColors.primaryColor,
            size: Responsive.scaleFont(24, context),
          ),
          onPressed: onAdd,
        ),
      ],
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
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
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
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.red,
                  size: Responsive.scaleFont(20, context),
                ),
                onPressed: () => controller.removeEducation(index),
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
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
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
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.red,
                  size: Responsive.scaleFont(20, context),
                ),
                onPressed: () => controller.removeExperience(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
