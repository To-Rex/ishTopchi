import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/services/show_toast.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final ThemeController themeController = Get.find<ThemeController>();

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
          Get.back();
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

  @override
  Widget build(BuildContext context) {
    final user = funcController.userMe.value.data;
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            'Tahrirlash'.tr,
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.scaleFont(19, context),
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: AppColors.textColor,
              size: Responsive.scaleFont(20, context),
            ),
            onPressed: () => Get.back(),
          ),
          elevation: 0,
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
                        color: AppColors.iconColor.withAlpha(150),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            profileController.selectedImage.value != null
                                ? Image.file(
                                  profileController.selectedImage.value!,
                                  fit: BoxFit.cover,
                                )
                                : (user?.profilePicture != null
                                    ? Image.network(
                                      _getProfileUrl(user!.profilePicture),
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(
                                      LucideIcons.user,
                                      color: AppColors.white,
                                      size: Responsive.scaleFont(50, context),
                                    )),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: Responsive.scaleHeight(35, context),
                                color: AppColors.cardColor.withAlpha(150),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: IconButton(
                                icon: Icon(
                                  LucideIcons.camera,
                                  color: AppColors.white,
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
                        profileController.regions,
                        profileController.selectedRegionId.value,
                        (newValue) {
                          if (newValue != null &&
                              newValue !=
                                  profileController.selectedRegionId.value) {
                            profileController.selectedRegionId.value = newValue;
                            profileController.districts.clear();
                            profileController.selectedDistrictId.value = '0';
                          }
                        },
                        'Viloyat'.tr,
                        LucideIcons.map,
                      ),
                      if (profileController.isLoadingRegions.value)
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
                      if (profileController.regions.isEmpty &&
                          !profileController.isLoadingRegions.value)
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
                        profileController.districts,
                        profileController.selectedDistrictId.value,
                        (newValue) {
                          if (newValue != null) {
                            profileController.selectedDistrictId.value =
                                newValue;
                          }
                        },
                        'Tuman'.tr,
                        LucideIcons.mapPin,
                      ),
                      if (profileController.isLoadingDistricts.value)
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
                      if (profileController.districts.isEmpty &&
                          !profileController.isLoadingDistricts.value &&
                          profileController.selectedRegionId.value.isNotEmpty)
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
                        profileController.isUpdatingProfile.value
                            ? null
                            : _saveProfile,
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
                        profileController.isUpdatingProfile.value
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
          builder: (context, child) {
            return Theme(
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
            );
          },
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
                  ? '$label tanlanishi shart'.tr
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
                  groupValue: profileController.selectedGender.value,
                  onChanged:
                      (value) =>
                          profileController.selectedGender.value = value ?? '',
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
                  groupValue: profileController.selectedGender.value,
                  onChanged:
                      (value) =>
                          profileController.selectedGender.value = value ?? '',
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
