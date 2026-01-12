import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/services/show_toast.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterController registerController = Get.find<RegisterController>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      registerController.selectedImage.value = File(image.path);
      Get.snackbar(
        'Muvaffaqiyatli'.tr,
        'Surat tanlandi'.tr,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiController().fetchRegions();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Ro‘yxatdan o‘tish'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.scaleFont(19, context),
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          elevation: 0,
          foregroundColor: AppColors.textColor,
        ),
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Responsive.scaleHeight(24, context)),
                Center(
                  child: Obx(
                    () => ClipOval(
                      child: Container(
                        width: Responsive.scaleWidth(120, context),
                        height: Responsive.scaleWidth(120, context),
                        color: AppColors.iconColor.withOpacity(0.2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            registerController.selectedImage.value != null
                                ? Image.file(
                                  registerController.selectedImage.value!,
                                  fit: BoxFit.cover,
                                )
                                : Icon(
                                  LucideIcons.user,
                                  color: AppColors.textColor,
                                  size: Responsive.scaleFont(50, context),
                                ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: Responsive.scaleHeight(35, context),
                                color: AppColors.cardColor.withOpacity(0.7),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: IconButton(
                                icon: Icon(
                                  LucideIcons.camera,
                                  color: AppColors.iconColor,
                                  size: Responsive.scaleFont(20, context),
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(24, context)),
                _buildTextField(
                  context,
                  firstNameController,
                  'Ism'.tr,
                  LucideIcons.user,
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                _buildTextField(
                  context,
                  lastNameController,
                  'Familiya'.tr,
                  LucideIcons.user,
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                _buildGenderSelection(context),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                _buildDateField(
                  context,
                  birthDateController,
                  'Tug‘ilgan sana'.tr,
                  LucideIcons.calendar,
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                Obx(
                  () => Stack(
                    children: [
                      _buildDropdown(
                        context,
                        registerController.regions,
                        registerController.selectedRegionId.value,
                        (newValue) {
                          if (newValue != null &&
                              newValue !=
                                  registerController.selectedRegionId.value) {
                            registerController.selectedRegionId.value =
                                newValue;
                            registerController.districts.clear();
                            registerController.selectedDistrictId.value = '0';
                          }
                        },
                        'Viloyat'.tr,
                        LucideIcons.map,
                      ),
                      if (registerController.isLoadingRegions.value)
                        Positioned(
                          right: Responsive.scaleWidth(10, context),
                          top: Responsive.scaleHeight(10, context),
                          child: SizedBox(
                            width: Responsive.scaleWidth(20, context),
                            height: Responsive.scaleHeight(20, context),
                            child: CircularProgressIndicator(
                              color: AppColors.iconColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      if (registerController.regions.isEmpty &&
                          !registerController.isLoadingRegions.value)
                        Positioned(
                          child: Text(
                            'Viloyatlar topilmadi'.tr,
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                Obx(
                  () => Stack(
                    children: [
                      _buildDropdown(
                        context,
                        registerController.districts,
                        registerController.selectedDistrictId.value,
                        (newValue) {
                          if (newValue != null) {
                            registerController.selectedDistrictId.value =
                                newValue;
                          }
                        },
                        'Tuman',
                        LucideIcons.mapPin,
                      ),
                      if (registerController.isLoadingDistricts.value)
                        Positioned(
                          right: Responsive.scaleWidth(10, context),
                          top: Responsive.scaleHeight(10, context),
                          child: SizedBox(
                            width: Responsive.scaleWidth(20, context),
                            height: Responsive.scaleHeight(20, context),
                            child: CircularProgressIndicator(
                              color: AppColors.iconColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      if (registerController.districts.isEmpty &&
                          !registerController.isLoadingDistricts.value &&
                          registerController.selectedRegionId.value.isNotEmpty)
                        Positioned(
                          child: Text(
                            'Tumanlar topilmadi'.tr,
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(24, context)),
                Obx(
                  () => ElevatedButton(
                    onPressed:
                        registerController.isRegistering.value
                            ? null
                            : () {
                              if (_formKey.currentState!.validate()) {
                                if (registerController
                                    .selectedGender
                                    .value
                                    .isEmpty) {
                                  Get.snackbar(
                                    'Xatolik'.tr,
                                    'Jins tanlanishi shart'.tr,
                                    backgroundColor: AppColors.red.withOpacity(
                                      0.8,
                                    ),
                                    colorText: AppColors.white,
                                  );
                                  return;
                                }
                                if (registerController
                                        .selectedRegionId
                                        .value
                                        .isEmpty ||
                                    registerController.isLoadingRegions.value) {
                                  Get.snackbar(
                                    'Xatolik'.tr,
                                    'Viloyat tanlanishi shart'.tr,
                                    backgroundColor: AppColors.red.withOpacity(
                                      0.8,
                                    ),
                                    colorText: AppColors.white,
                                  );
                                  return;
                                }
                                if (registerController
                                            .selectedDistrictId
                                            .value ==
                                        '0' ||
                                    registerController
                                        .isLoadingDistricts
                                        .value) {
                                  Get.snackbar(
                                    'Xatolik'.tr,
                                    'Tuman tanlanishi shart'.tr,
                                    backgroundColor: AppColors.red.withOpacity(
                                      0.8,
                                    ),
                                    colorText: AppColors.white,
                                  );
                                  return;
                                }
                                registerController.registerUser(
                                  firstNameController.text,
                                  lastNameController.text,
                                  registerController.selectedGender.value,
                                  birthDateController.text,
                                  registerController.selectedRegionId.value,
                                  registerController.selectedDistrictId.value,
                                  registerController.selectedImage.value,
                                );
                              } else {
                                ShowToast.show(
                                  'Xatolik'.tr,
                                  'Iltimos, barcha majburiy maydonlarni to‘ldiring'
                                      .tr,
                                  3,
                                  1,
                                  duration: 2,
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.scaleWidth(12, context),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.scaleHeight(12, context),
                        horizontal: Responsive.scaleWidth(24, context),
                      ),
                      elevation: 2,
                    ),
                    child:
                        registerController.isRegistering.value
                            ? SizedBox(
                              width: Responsive.scaleWidth(20, context),
                              height: Responsive.scaleHeight(20, context),
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              'Saqlash'.tr,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(16, context),
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      validator:
          (value) =>
              value == null || value.trim().isEmpty
                  ? '$label ${'to‘ldirilishi shart'.tr}'
                  : null,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(18, context),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.iconColor,
          fontSize: Responsive.scaleFont(14, context),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: Responsive.scaleFont(14, context),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    final ThemeController themeController = Get.find<ThemeController>();
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator:
          (value) =>
              value == null || value.trim().isEmpty
                  ? '$label ${'tanlanishi shart'.tr}'
                  : null,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(
            controller.text.isNotEmpty ? controller.text : '1990-01-01',
          ),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder:
              (context, child) => Theme(
                data:
                    themeController.isDarkMode.value
                        ? ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.iconColor,
                            onPrimary: AppColors.white,
                            surface: AppColors.cardColor,
                          ),
                        )
                        : ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primaryColor,
                            onPrimary: AppColors.white,
                            surface: AppColors.cardColor,
                          ),
                        ),
                child: child!,
              ),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toLocal().toString().split(' ')[0];
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(18, context),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.iconColor,
          fontSize: Responsive.scaleFont(14, context),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: Responsive.scaleFont(14, context),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    List<Map<String, dynamic>> items,
    String value,
    Function(String?) onChanged,
    String label,
    IconData icon,
  ) {
    return DropdownButtonFormField2<String>(
      value:
          value.isNotEmpty &&
                  items.any((item) => item['id'].toString() == value)
              ? value
              : null,
      isExpanded: true,
      validator:
          (val) =>
              val == null || val.isEmpty || val == '0'
                  ? '$label ${'tanlanishi shart'.tr}'
                  : null,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(18, context),
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.iconColor,
          fontSize: Responsive.scaleFont(14, context),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: Responsive.scaleHeight(200, context),
        width: Responsive.scaleWidth(250, context),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          boxShadow: [
            BoxShadow(color: AppColors.cardColor.withAlpha(100), blurRadius: 5),
          ],
        ),
        elevation: 4,
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          LucideIcons.chevronDown,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(18, context),
        ),
      ),
      style: TextStyle(
        color: AppColors.textColor,
        fontSize: Responsive.scaleFont(14, context),
      ),
      items:
          items.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(
                item['name'] ?? 'Noma’lum'.tr,
                style: TextStyle(fontSize: Responsive.scaleFont(14, context)),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      hint: Text(
        items.isEmpty ? 'Ma’lumot topilmadi'.tr : 'Tanlang'.tr,
        style: TextStyle(
          color: AppColors.iconColor,
          fontSize: Responsive.scaleFont(14, context),
        ),
      ),
    );
  }

  Widget _buildGenderSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jins'.tr,
          style: TextStyle(
            color: AppColors.iconColor,
            fontSize: Responsive.scaleFont(14, context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Responsive.scaleHeight(8, context)),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Erkak'.tr,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                  value: '1',
                  groupValue: registerController.selectedGender.value,
                  onChanged:
                      (value) =>
                          registerController.selectedGender.value = value ?? '',
                  activeColor: AppColors.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              SizedBox(width: Responsive.scaleWidth(16, context)),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Ayol'.tr,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                  ),
                  value: '2',
                  groupValue: registerController.selectedGender.value,
                  onChanged:
                      (value) =>
                          registerController.selectedGender.value = value ?? '',
                  activeColor: AppColors.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
