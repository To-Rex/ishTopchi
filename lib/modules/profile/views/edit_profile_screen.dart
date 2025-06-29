import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  String? selectedDistrictId = '1';

  @override
  void initState() {
    super.initState();
    final user = funcController.userMe.value?.data;
    if (user != null) {
      firstNameController.text = user.firstName ?? 'Alisher';
      lastNameController.text = user.lastName ?? 'Diyorov';
      birthDateController.text = user.birthDate?.split('T')[0] ?? '1990-01-01';
      selectedDistrictId ='1';
    }
  }

  Future<void> _saveProfile() async {
    final token = funcController.getToken();
    if (token == null) {
      Get.snackbar('Xatolik', 'Token mavjud emas');
      return;
    }

    final success = await apiController.completeRegistration(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      districtId: int.parse(selectedDistrictId!),
      birthDate: birthDateController.text,
      token: token,
    );

    if (success) {
      Get.snackbar('Muvaffaqiyat', 'Profil yangilandi', backgroundColor: AppColors.lightBlue.withOpacity(0.8));
      await profileController.loadUser();
      Get.back();
    } else {
      Get.snackbar('Xatolik', 'Profilni yangilashda xatolik', backgroundColor: Colors.redAccent.withOpacity(0.8));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = funcController.userMe.value?.data;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tahrirlash', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
        backgroundColor: AppColors.darkNavy,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.darkNavy,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profil rasm va asosiy ma'lumotlar
            CircleAvatar(
              radius: Responsive.scaleWidth(60, context),
              backgroundImage: NetworkImage(
                user?.profilePicture ?? 'https://help.tithe.ly/hc/article_attachments/18804144460951',
              ),
              backgroundColor: AppColors.darkBlue.withOpacity(0.3),
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
            Text(
              'Foydalanuvchi ID: ${user?.id ?? 1}',
              style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
            ),
            Text(
              'Email: ${user?.authProviders?.first.email ?? 'no email'}',
              style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Tahrirlanadigan maydonlar
            _buildTextField(firstNameController, 'Ism', Icons.person),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildTextField(lastNameController, 'Familiya', Icons.person_outline),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildDateField(birthDateController, 'Tug‘ilgan sana'),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildDropdown(selectedDistrictId, (newValue) => setState(() => selectedDistrictId = newValue)),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Saqlash tugmasi
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(15, context))),
                padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context), horizontal: Responsive.scaleWidth(40, context)),
                elevation: 2,
              ),
              child: Text(
                'Saqlash',
                style: TextStyle(
                  fontSize: Responsive.scaleFont(16, context),
                  color: AppColors.darkNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
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
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_today, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
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
          setState(() {
            controller.text = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
    );
  }

  Widget _buildDropdown(String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.location_city, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
        labelText: 'Tuman',
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
      dropdownColor: AppColors.darkBlue,
      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
      iconEnabledColor: AppColors.lightBlue,
      items: ['1', '2', '3'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('Tuman $value', style: TextStyle(fontSize: Responsive.scaleFont(14, context))),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}