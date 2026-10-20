import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_form.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/services/show_toast.dart';
import '../controllers/profile_controller.dart';

/// Profilni tahrirlash.
///
/// Shakl qismlari [RegisterScreen] bilan bir xil — ikkalasi ham
/// `common/widgets/app_form.dart` dagi widgetlardan foydalanadi.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = funcController.userMe.value.data;
    if (user != null) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      birthDateController.text = user.birthDate?.split('T')[0] ?? '';
      profileController.selectedGender.value =
          user.gender == 'MALE' ? '1' : '2';
      if (user.district != null && user.district!.region != null) {
        profileController.selectedRegionId.value =
            user.district!.region!.id.toString();
        profileController.selectedDistrictId.value =
            user.district!.id.toString();
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  String _getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    if (url == null || url.trim().isEmpty) {
      return 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    }
    url = url.trim();
    return url.startsWith('http')
        ? url
        : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileController.selectedImage.value = File(image.path);
      ShowToast.show('Muvaffaqiyatli'.tr, 'Surat tanlandi'.tr, 1, 1);
    }
  }

  Future<void> _saveProfile() async {
    final token = funcController.getToken();
    if (token == null) {
      ShowToast.show('Xatolik'.tr, 'Tizimga kirish talab qilinadi'.tr, 2, 1);
      return;
    }
    if (_formKey.currentState!.validate()) {
      if (profileController.selectedGender.value.isEmpty) {
        ShowToast.show('Xatolik'.tr, 'Jins tanlanishi shart'.tr, 2, 1);
        return;
      }
      if (profileController.selectedRegionId.value.isEmpty ||
          profileController.isLoadingRegions.value) {
        ShowToast.show('Xatolik'.tr, 'Viloyat tanlanishi shart'.tr, 2, 1);
        return;
      }
      if (profileController.selectedDistrictId.value == '0' ||
          profileController.isLoadingDistricts.value) {
        ShowToast.show('Xatolik'.tr, 'Tuman tanlanishi shart'.tr, 2, 1);
        return;
      }
      try {
        profileController.isUpdatingProfile.value = true;
        final success = await apiController.updateProfile(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          districtId: int.parse(profileController.selectedDistrictId.value),
          birthDate: birthDateController.text,
          gender:
              profileController.selectedGender.value == '1' ? 'MALE' : 'FEMALE',
          image: profileController.selectedImage.value,
        );
        if (success) {
          await profileController.loadUser();
          if (!mounted) return;
          Navigator.of(context).pop();
          ShowToast.show(
            'Muvaffaqiyatli'.tr,
            'Profil muvaffaqiyatli yangilandi'.tr,
            1,
            1,
          );
        } else {
          ShowToast.show(
            'Xatolik'.tr,
            'Profilni yangilashda muammo yuz berdi'.tr,
            2,
            1,
          );
        }
      } catch (e) {
        debugPrint('saveProfile xatolik: $e');
        ShowToast.show(
          'Xatolik'.tr,
          'Profil yangilashda xato yuz berdi'.tr,
          2,
          1,
        );
      } finally {
        profileController.isUpdatingProfile.value = false;
      }
    } else {
      ShowToast.show(
        'Xatolik'.tr,
        'Iltimos, barcha maydonlarni to‘ldiring'.tr,
        2,
        1,
      );
    }
  }

  Future<void> _pickDate() async {
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

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Tahrirlash'.tr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppReveal(
                child: Center(
                  child: Obx(() {
                    final user = funcController.userMe.value.data;
                    return AppAvatarPicker(
                      file: profileController.selectedImage.value,
                      networkUrl:
                          user?.profilePicture != null
                              ? _getProfileUrl(user!.profilePicture)
                              : null,
                      onPick: _pickImage,
                    );
                  }),
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
                    selected: profileController.selectedGender.value,
                    onChanged:
                        (value) =>
                            profileController.selectedGender.value = value,
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
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 14),
              AppReveal(
                delay: const Duration(milliseconds: 220),
                child: Obx(
                  () => AppSelectField(
                    items: profileController.regions,
                    value: profileController.selectedRegionId.value,
                    label: 'Viloyat'.tr,
                    icon: LucideIcons.map,
                    loading: profileController.isLoadingRegions.value,
                    emptyMessage: 'Viloyatlar topilmadi'.tr,
                    showEmptyMessage:
                        profileController.regions.isEmpty &&
                        !profileController.isLoadingRegions.value,
                    onChanged: (newValue) {
                      if (newValue != null &&
                          newValue !=
                              profileController.selectedRegionId.value) {
                        profileController.selectedRegionId.value = newValue;
                        profileController.districts.clear();
                        profileController.selectedDistrictId.value = '0';
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
                    items: profileController.districts,
                    value: profileController.selectedDistrictId.value,
                    label: 'Tuman'.tr,
                    icon: LucideIcons.mapPin,
                    loading: profileController.isLoadingDistricts.value,
                    emptyMessage: 'Tumanlar topilmadi'.tr,
                    showEmptyMessage:
                        profileController.districts.isEmpty &&
                        !profileController.isLoadingDistricts.value,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        profileController.selectedDistrictId.value = newValue;
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
                    loading: profileController.isUpdatingProfile.value,
                    onPressed:
                        profileController.isUpdatingProfile.value
                            ? null
                            : _saveProfile,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
