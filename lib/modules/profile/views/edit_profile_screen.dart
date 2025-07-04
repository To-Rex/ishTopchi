import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  EditProfileScreen({super.key});

  Future<void> _saveProfile() async {
    final token = funcController.getToken();
    if (token == null) {
      Get.snackbar('Xatolik', 'Token mavjud emas');
      return;
    }

/*    final success = await apiController.completeRegistration(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      districtId: int.parse(profileController.selectedDistrictId.value),
      birthDate: birthDateController.text,
      token: token,
    );*/

    /*if (success) {
      Get.snackbar('Muvaffaqiyat', 'Profil yangilandi', backgroundColor: AppColors.lightBlue.withOpacity(0.8));
      await profileController.loadUser();
      Get.back();
    } else {
      Get.snackbar('Xatolik', 'Profilni yangilashda xatolik', backgroundColor: Colors.redAccent.withOpacity(0.8));
    }*/
  }

  @override
  Widget build(BuildContext context) {
    final user = funcController.userMe.value?.data;
    if (user != null) {
      firstNameController.text = user.firstName ?? 'Alisher';
      lastNameController.text = user.lastName ?? 'Diyorov';
      birthDateController.text = user.birthDate?.split('T')[0] ?? '1990-01-01';
    }

    final screenWidth = Responsive.screenWidth(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tahrirlash', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
        backgroundColor: AppColors.darkNavy,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
          onPressed: () => Get.back(),
        ),
        elevation: 0
      ),
      backgroundColor: AppColors.darkNavy,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: Responsive.scaleWidth(60, context),
              backgroundImage: NetworkImage(user?.profilePicture ?? 'https://help.tithe.ly/hc/article_attachments/18804144460951'),
              backgroundColor: AppColors.darkBlue.withOpacity(0.3)
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            Text('Foydalanuvchi ID: ${user?.id ?? 1}', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context))),
            Text('Email: ${user?.authProviders?.first.email ?? 'no email'}', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context))),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            _buildTextField(context, firstNameController, 'Ism', LucideIcons.user),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildTextField(context, lastNameController, 'Familiya', LucideIcons.user),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildDateField(context, birthDateController, 'Tug‘ilgan sana', LucideIcons.calendar),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            Obx(() => _buildDropdown(context, profileController.regions, profileController.selectedRegionId.value, (newValue) {
                  profileController.selectedRegionId.value = newValue!;
                  profileController.loadDistricts(int.parse(newValue));
                  }, 'Viloyat', LucideIcons.map)),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            Obx(() => _buildDropdown(context, profileController.districts, profileController.selectedDistrictId.value, (newValue) => profileController.selectedDistrictId.value = newValue!, 'Tuman', LucideIcons.mapPin)),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(15, context))),
                padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context), horizontal: Responsive.scaleWidth(40, context)),
                elevation: 2,
              ),
              child: Text('Saqlash', style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: AppColors.white, fontWeight: FontWeight.w600))
            )
          ]
        )
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
        fillColor: AppColors.darkBlue.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5)
        )
      ),
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))
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
        fillColor: AppColors.darkBlue.withOpacity(0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5)
        )
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
              data: ThemeData.dark().copyWith(colorScheme: ColorScheme.dark(primary: AppColors.lightBlue, onPrimary: AppColors.white, surface: AppColors.darkBlue)),
              child: child!
            );
          }
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toLocal().toString().split(' ')[0];
        }
      }
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
      value: value.isNotEmpty ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
        labelText: label,
        labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
        filled: true,
        fillColor: AppColors.darkBlue.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: Responsive.scaleHeight(400, context),
        width: Responsive.scaleWidth(250, context),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
        ),
        elevation: 5,
      ),
      iconStyleData: IconStyleData(
        icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
      ),
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
      items: items.map<DropdownMenuItem<String>>((item) {
        return DropdownMenuItem<String>(
          value: item['id'].toString(),
          child: Text(
            item['name'],
            style: TextStyle(fontSize: Responsive.scaleFont(14, context)),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      hint: Text('Tanlang', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
    );
  }
}