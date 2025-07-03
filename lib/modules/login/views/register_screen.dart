import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  final ApiController apiController = Get.find<ApiController>();
  final TextEditingController firstNameController = TextEditingController(text: 'Dilshodjon');
  final TextEditingController lastNameController = TextEditingController(text: 'Haydarov');
  final TextEditingController birthDateController = TextEditingController(text: '2025-06-28');
  final RegisterController registerController = Get.find<RegisterController>();
  final ImagePicker _picker = ImagePicker();

  RegisterScreen({super.key});

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      registerController.selectedImage.value = File(image.path); // Suratni saqlash
      Get.snackbar('Muvaffaqiyat', 'Surat tanlandi', backgroundColor: AppColors.lightBlue.withOpacity(0.8));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Ro‘yxatdan o‘tish', style: TextStyle(color: AppColors.lightGray, fontWeight: FontWeight.bold, fontSize: Responsive.scaleFont(19, context))), backgroundColor: AppColors.darkNavy, centerTitle: true, elevation: 0),
        backgroundColor: AppColors.darkNavy,
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: apiController.fetchRegions(),
            builder: (context, regionSnapshot) {
              if (regionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
              }
              if (regionSnapshot.hasError || !regionSnapshot.hasData || regionSnapshot.data!.isEmpty) {
                return Center(child: Text('Viloyatlar yuklanmadi', style: TextStyle(color: AppColors.lightGray)));
              }

              final regions = regionSnapshot.data!;
              // Dastlabki viloyatni tanlash
              if (registerController.selectedRegionId.value.isEmpty && regions.isNotEmpty) {
                registerController.selectedRegionId.value = regions.first['id'].toString();
              }

              return FutureBuilder<List<Map<String, dynamic>>>(
                  future: registerController.selectedRegionId.value.isNotEmpty
                      ? apiController.fetchDistricts(int.parse(registerController.selectedRegionId.value))
                      : Future.value(<Map<String, dynamic>>[]),
                  builder: (context, districtSnapshot) {
                    if (districtSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
                    }
                    final districts = districtSnapshot.data ?? [];
                    if (districts.isEmpty && registerController.selectedRegionId.value.isNotEmpty) {
                      registerController.loadDistricts(int.parse(registerController.selectedRegionId.value));
                    }

                    return SingleChildScrollView(
                        padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: Responsive.scaleHeight(24, context)),
                              Center(
                                child: Obx(() => ClipOval(
                                  child: Container(
                                    width: Responsive.scaleWidth(120, context),
                                    height: Responsive.scaleWidth(120, context),
                                    color: AppColors.darkBlue.withOpacity(0.3),
                                    child: Stack(
                                      children: [
                                        // 📌 1. Background rasm yoki icon
                                        Positioned.fill(
                                          child: registerController.selectedImage.value != null
                                              ? Image.file(
                                            registerController.selectedImage.value!,
                                            fit: BoxFit.cover,
                                          )
                                              : Icon(
                                            LucideIcons.user,
                                            color: AppColors.lightGray,
                                            size: Responsive.scaleFont(50, context),
                                          ),
                                        ),

                                        // 📌 2. Pastki yarimoy fon
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: Responsive.scaleHeight(35, context),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkBlue.withAlpha(150),
                                            ),
                                          ),
                                        ),

                                        // 📌 3. Kamera tugmasi
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: IconButton(
                                            icon: Icon(
                                              LucideIcons.camera,
                                              color: AppColors.lightBlue,
                                              size: Responsive.scaleFont(20, context),
                                            ),
                                            onPressed: _pickImage,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ),
                              SizedBox(height: Responsive.scaleHeight(24, context)),
                              _buildTextField(context, firstNameController, 'Ism', LucideIcons.user),
                              SizedBox(height: Responsive.scaleHeight(16, context)),
                              _buildTextField(context, lastNameController, 'Familiya', LucideIcons.user),
                              SizedBox(height: Responsive.scaleHeight(16, context)),
                              _buildGenderSelection(context),
                              SizedBox(height: Responsive.scaleHeight(16, context)),
                              _buildDateField(context, birthDateController, 'Tug‘ilgan sana', LucideIcons.calendar),
                              SizedBox(height: Responsive.scaleHeight(16, context)),
                              Obx(() => _buildDropdown(context, regions,
                                registerController.selectedRegionId.value, (newValue) {
                                  if (newValue != null) {
                                    registerController.selectedRegionId.value = newValue;
                                    registerController.loadDistricts(int.parse(newValue));
                                  }
                                },
                                'Viloyat',
                                LucideIcons.map,
                              )),
                              SizedBox(height: Responsive.scaleHeight(16, context)),
                              Obx(() => _buildDropdown(
                                  context,
                                  registerController.districts,
                                  registerController.selectedDistrictId.value, (newValue) => registerController.selectedDistrictId.value = newValue ?? '0', 'Tuman',
                                  LucideIcons.mapPin
                              )),
                              SizedBox(height: Responsive.scaleHeight(24, context)),
                              ElevatedButton(
                                  onPressed: () {
                                    print('Ro‘yxatdan o‘tish: $firstNameController.text, $lastNameController.text, '
                                        '${registerController.selectedDistrictId.value}, $birthDateController.text, ${registerController.selectedGender.value}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.lightBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context))),
                                      padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context), horizontal: Responsive.scaleWidth(24, context)),
                                      elevation: 2
                                  ),
                                  child: Text('Saqlash', style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: AppColors.white, fontWeight: FontWeight.w600))
                              )
                            ]
                        )
                    );
                  }
              );
            }
        )
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
        filled: true,
        fillColor: AppColors.darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
      ),
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
    );
  }

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
        filled: true,
        fillColor: AppColors.darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
      ),
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(controller.text.isNotEmpty ? controller.text : '1990-01-01'),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.lightBlue,
                  onPrimary: AppColors.white,
                  surface: AppColors.darkBlue,
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
      value: value.isNotEmpty && items.any((item) => item['id'].toString() == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
          labelText: label,
          labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
          filled: true,
          fillColor: AppColors.darkBlue,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)), borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5))
      ),
      dropdownStyleData: DropdownStyleData(
          maxHeight: Responsive.scaleHeight(200, context),
          width: Responsive.scaleWidth(250, context),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
            boxShadow: [BoxShadow(color: AppColors.darkBlue.withAlpha(100), blurRadius: 5)],
          ),
          elevation: 4
      ),
      iconStyleData: IconStyleData(icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: Responsive.scaleFont(18, context))),
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
            value: item['id'].toString(),
            child: Text(item['name'] ?? 'Noma’lum', style: TextStyle(fontSize: Responsive.scaleFont(14, context)), overflow: TextOverflow.ellipsis)
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text('Tanlang', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
    );
  }

  Widget _buildGenderSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jins',
          style: TextStyle(
            color: AppColors.lightGray,
            fontSize: Responsive.scaleFont(14, context),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Responsive.scaleHeight(8, context)),
        Obx(() => Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Erkak', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))),
                value: '1',
                groupValue: registerController.selectedGender.value,
                onChanged: (value) => registerController.selectedGender.value = value ?? '',
                activeColor: AppColors.lightBlue,
                contentPadding: EdgeInsets.zero,
                splashRadius: 10,
                dense: true,
              ),
            ),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Expanded(
              child: RadioListTile<String>(
                title: Text('Ayol', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))),
                value: '2',
                groupValue: registerController.selectedGender.value,
                onChanged: (value) => registerController.selectedGender.value = value ?? '',
                activeColor: AppColors.lightBlue,
                contentPadding: EdgeInsets.zero,
                splashRadius: 10,
                dense: true,
              ),
            ),
          ],
        )),
      ],
    );
  }
}