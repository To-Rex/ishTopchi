import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/models/resumes_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/create_resume_controller.dart';

class CreateResumeScreen extends StatelessWidget {
  final ResumesData? resume;

  const CreateResumeScreen({super.key, this.resume});

  @override
  Widget build(BuildContext context) {
    // Kontrollerni yaratish yoki topish
    final controller = Get.put(CreateResumeController());
    controller.loadResumeData(resume); // Resume ma'lumotlarini yuklash

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(25, context)),
          onPressed: () => Get.back(),
        ),
        title: Text('Rezyume yaratish'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(20, context), fontWeight: FontWeight.bold)),
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
                initialValue: controller.titleController.value,
                onChanged: (value) => controller.titleController.value = value,
              ),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Tavsif
              _buildTextField(
                context,
                label: 'Tavsif'.tr,
                initialValue: controller.contentController.value,
                maxLines: 4,
                onChanged: (value) => controller.contentController.value = value,
              ),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Fayl tanlash
              _buildFilePicker(context, controller),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Ta'lim bo'limi
              _buildSectionTitle(context, 'Ta’lim'.tr, () => controller.addEducation()),
              Obx(() => Column(
                children: controller.educationList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final education = entry.value;
                  return _buildEducationField(context, controller, index, education);
                }).toList(),
              )),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Tajriba bo'limi
              _buildSectionTitle(context, 'Tajriba'.tr, () => controller.addExperience()),
              Obx(() => Column(
                children: controller.experienceList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final experience = entry.value;
                  return _buildExperienceField(context, controller, index, experience);
                }).toList(),
              )),
              SizedBox(height: Responsive.scaleHeight(20, context)),
              // Saqlash/Yangilash tugmasi
              Obx(() => Center(
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: AppColors.lightBlue)
                    : ElevatedButton(
                  onPressed: controller.saveResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    fixedSize: Size(double.infinity, Responsive.scaleHeight(48, context)),
                    minimumSize: Size(double.infinity, Responsive.scaleHeight(48, context)),
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(40, context),
                      vertical: Responsive.scaleHeight(12, context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    controller.isEditing.value ? 'Yangilash'.tr : 'Saqlash'.tr,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: Responsive.scaleFont(16, context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
              SizedBox(height: Responsive.scaleHeight(60, context)),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, String? initialValue, int maxLines = 1, required Function(String) onChanged}) {
    final textController = TextEditingController(text: initialValue);
    return TextField(
      maxLines: maxLines,
      controller: textController,
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
        filled: true,
        fillColor: AppColors.lightBlue.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.scaleWidth(16, context),
          vertical: Responsive.scaleHeight(12, context),
        ),
      ),
      onChanged: (value) {
        onChanged(value);
      },
    );
  }

  Widget _buildFilePicker(BuildContext context, CreateResumeController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.pickFile,
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
        decoration: BoxDecoration(
          color: AppColors.lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
            SizedBox(width: Responsive.scaleWidth(10, context)),
            Expanded(
              child: Text(
                controller.selectedFile.value == null
                    ? resume?.fileUrl != null
                    ? resume!.fileUrl!.split('/').last
                    : 'Fayl tanlash'.tr
                    : controller.selectedFile.value!.path.split('/').last,
                style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle, color: AppColors.lightBlue, size: Responsive.scaleFont(24, context)),
          onPressed: onAdd,
        ),
      ],
    );
  }

  Widget _buildEducationField(BuildContext context, CreateResumeController controller, int index, Education education) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.scaleHeight(12, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withAlpha(100),
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withOpacity(0.1),
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
              initialValue: education.degree,
              onChanged: (value) => education.degree = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Yo‘nalish'.tr,
              initialValue: education.field,
              onChanged: (value) => education.field = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Muassasa'.tr,
              initialValue: education.institution,
              onChanged: (value) => education.institution = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Davri (masalan, 2018-2022)'.tr,
              initialValue: education.period,
              onChanged: (value) => education.period = value,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent, size: Responsive.scaleFont(20, context)),
                onPressed: () => controller.removeEducation(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceField(BuildContext context, CreateResumeController controller, int index, Experience experience) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.scaleHeight(12, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withAlpha(100),
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withOpacity(0.1),
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
              initialValue: experience.position,
              onChanged: (value) => experience.position = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Kompaniya'.tr,
              initialValue: experience.company,
              onChanged: (value) => experience.company = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Davri (masalan, 2022-Hozir)'.tr,
              initialValue: experience.period,
              onChanged: (value) => experience.period = value,
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            _buildTextField(
              context,
              label: 'Tavsif'.tr,
              initialValue: experience.description,
              maxLines: 3,
              onChanged: (value) => experience.description = value,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent, size: Responsive.scaleFont(20, context)),
                onPressed: () => controller.removeExperience(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}