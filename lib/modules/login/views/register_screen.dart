import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_form.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/services/show_toast.dart';
import '../controllers/register_controller.dart';

/// Roʻyxatdan oʻtish shakli.
///
/// Maydonlarning bezagi mavzudagi `inputDecorationTheme` dan keladi —
/// avval har bir maydon uchun 30 qatordan `InputDecoration` yozilgan edi.
/// Umumiy qismlar [AppAvatarPicker], [AppSelectField] va
/// [AppGenderSelector] ga chiqarildi: profilni tahrirlash ekrani ham
/// xuddi shularni ishlatadi.
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

    return AppScreen(
      title: 'Ro‘yxatdan o‘tish'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppReveal(
                child: Center(
                  child: Obx(
                    () => AppAvatarPicker(
                      file: registerController.selectedImage.value,
                      onPick: _pickImage,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              AppReveal(
                delay: const Duration(milliseconds: 60),
                child: AppFormField(
                  controller: firstNameController,
                  label: 'Ism'.tr,
                  icon: LucideIcons.user,
                ),
              ),
              const SizedBox(height: 14),
              AppReveal(
                delay: const Duration(milliseconds: 100),
                child: AppFormField(
                  controller: lastNameController,
                  label: 'Familiya'.tr,
                  icon: LucideIcons.user,
                ),
              ),
              const SizedBox(height: 16),
              AppReveal(
                delay: const Duration(milliseconds: 140),
                child: Obx(
                  () => AppGenderSelector(
                    selected: registerController.selectedGender.value,
                    onChanged:
                        (value) =>
                            registerController.selectedGender.value = value,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppReveal(
                delay: const Duration(milliseconds: 180),
                child: AppFormField(
                  controller: birthDateController,
                  label: 'Tug‘ilgan sana'.tr,
                  icon: LucideIcons.calendar,
                  readOnly: true,
                  requiredMessage:
                      '${'Tug‘ilgan sana'.tr} ${'tanlanishi shart'.tr}',
                  onTap: () => _pickDate(context),
                ),
              ),
              const SizedBox(height: 14),
              AppReveal(
                delay: const Duration(milliseconds: 220),
                child: Obx(
                  () => AppSelectField(
                    items: registerController.regions,
                    value: registerController.selectedRegionId.value,
                    label: 'Viloyat'.tr,
                    icon: LucideIcons.map,
                    loading: registerController.isLoadingRegions.value,
                    emptyMessage: 'Viloyatlar topilmadi'.tr,
                    showEmptyMessage:
                        registerController.regions.isEmpty &&
                        !registerController.isLoadingRegions.value,
                    onChanged: (newValue) {
                      if (newValue != null &&
                          newValue !=
                              registerController.selectedRegionId.value) {
                        registerController.selectedRegionId.value = newValue;
                        registerController.districts.clear();
                        registerController.selectedDistrictId.value = '0';
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppReveal(
                delay: const Duration(milliseconds: 260),
                child: Obx(
                  () => AppSelectField(
                    items: registerController.districts,
                    value: registerController.selectedDistrictId.value,
                    label: 'Tuman',
                    icon: LucideIcons.mapPin,
                    loading: registerController.isLoadingDistricts.value,
                    emptyMessage: 'Tumanlar topilmadi'.tr,
                    showEmptyMessage:
                        registerController.districts.isEmpty &&
                        !registerController.isLoadingDistricts.value &&
                        registerController.selectedRegionId.value.isNotEmpty,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        registerController.selectedDistrictId.value = newValue;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 26),
              AppReveal(
                delay: const Duration(milliseconds: 310),
                child: Obx(
                  () => AppButton(
                    label: 'Saqlash'.tr,
                    filled: true,
                    loading: registerController.isRegistering.value,
                    onPressed:
                        registerController.isRegistering.value ? null : _submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    // Sana tanlagich ilovaning oʻz mavzusidan foydalanadi — avval
    // `ThemeData.dark()`/`light()` qoʻlda qurilar edi.
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(
        birthDateController.text.isNotEmpty
            ? birthDateController.text
            : '1990-01-01',
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      birthDateController.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  /// Saqlash tugmasining mantigʻi — avvalgidek tekshiruvlar ketma-ketligi.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (registerController.selectedGender.value.isEmpty) {
        _error('Jins tanlanishi shart'.tr);
        return;
      }
      if (registerController.selectedRegionId.value.isEmpty ||
          registerController.isLoadingRegions.value) {
        _error('Viloyat tanlanishi shart'.tr);
        return;
      }
      if (registerController.selectedDistrictId.value == '0' ||
          registerController.isLoadingDistricts.value) {
        _error('Tuman tanlanishi shart'.tr);
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
        'Iltimos, barcha majburiy maydonlarni to‘ldiring'.tr,
        3,
        1,
        duration: 2,
      );
    }
  }

  void _error(String message) {
    Get.snackbar(
      'Xatolik'.tr,
      message,
      backgroundColor: AppColors.red.withValues(alpha: 0.8),
      colorText: AppColors.white,
    );
  }
}
