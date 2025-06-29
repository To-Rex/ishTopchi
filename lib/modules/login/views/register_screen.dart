import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kontrollerlar
    final TextEditingController firstNameController = TextEditingController(text: 'Dilshodjon');
    final TextEditingController lastNameController = TextEditingController(text: 'Haydarov');
    final TextEditingController birthDateController = TextEditingController(
      text: '2025-06-28', // Faqat sana qismi
    );
    String? selectedDistrictId = '0'; // district_id uchun boshlang‘ich qiymat

    return Scaffold(
      appBar: AppBar(
        title: Text('Ro\'yhatdan o\'tish', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.darkNavy,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sarlavha
                Text(
                  'Ro\'yhatdan o\'tish',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(24, context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(24, context)),
                // First Name
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Ism',
                    labelStyle: TextStyle(color: AppColors.lightGray),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide(color: AppColors.lightBlue),
                    ),
                  ),
                  style: TextStyle(color: AppColors.white),
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                // Last Name
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Familiya',
                    labelStyle: TextStyle(color: AppColors.lightGray),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide(color: AppColors.lightBlue),
                    ),
                  ),
                  style: TextStyle(color: AppColors.white),
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                // District
                DropdownButtonFormField<String>(
                  value: selectedDistrictId,
                  decoration: InputDecoration(
                    labelText: 'Tuman',
                    labelStyle: TextStyle(color: AppColors.lightGray),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide(color: AppColors.lightBlue),
                    ),
                  ),
                  dropdownColor: AppColors.darkBlue,
                  style: TextStyle(color: AppColors.white),
                  iconEnabledColor: AppColors.lightBlue,
                  items: <String>['0', '1', '2'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == '0' ? 'Tanlang' : 'Tuman $value'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedDistrictId = newValue;
                  },
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                // Birth Date
                TextField(
                  controller: birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Tug\'ilgan sana',
                    labelStyle: TextStyle(color: AppColors.lightGray),
                    filled: true,
                    fillColor: AppColors.darkBlue.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                      borderSide: BorderSide(color: AppColors.lightBlue),
                    ),
                  ),
                  style: TextStyle(color: AppColors.white),
                  readOnly: true, // Faqat tanlash orqali o‘zgartirish
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.parse('2025-06-28'),
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
                      birthDateController.text = pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                ),
                SizedBox(height: Responsive.scaleHeight(24, context)),
                // Tasdiqlash tugmasi
                ElevatedButton(
                  onPressed: () {
                    // Ro'yhatdan o'tish logikasi shu yerga qo'shiladi
                    print('Ro\'yhatdan o\'tish: $firstNameController.text, $lastNameController.text, '
                        '$selectedDistrictId, $birthDateController.text');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.scaleHeight(12, context),
                    ),
                  ),
                  child: Text(
                    'Tasdiqlash',
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(16, context),
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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
}