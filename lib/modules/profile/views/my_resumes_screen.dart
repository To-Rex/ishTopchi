import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key});

  @override
  MyResumesScreenState createState() => MyResumesScreenState();
}

class MyResumesScreenState extends State<MyResumesScreen> {
  final ProfileController profileController = Get.find<ProfileController>();
  final FuncController funcController = Get.find<FuncController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mening Rezumelarim', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
        backgroundColor: AppColors.darkNavy,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.darkNavy,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Qo'shish tugmasi
            ElevatedButton(
              onPressed: () => _showAddResumeDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context))),
                padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(10, context), horizontal: Responsive.scaleWidth(20, context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: AppColors.white, size: Responsive.scaleFont(16, context)),
                  SizedBox(width: Responsive.scaleWidth(8, context)),
                  Text(
                    'Yangi qo‘shish',
                    style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: AppColors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(20, context)),
            // Resume ro'yxati
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Masalan, 3 ta resume, real ma'lumotlar uchun funcController dan oling
                itemBuilder: (context, index) {
                  return _buildResumeItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeItem(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.scaleHeight(12, context)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withAlpha(50),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(8, context)),
          leading: Icon(Icons.description, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
          title: Text(
            'Resume ${index + 1}',
            style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Yaratilgan sana: 2025-06-01',
            style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent, size: Responsive.scaleFont(18, context)),
            onPressed: () => _confirmDelete(index),
          ),
        ),
      ),
    );
  }

  void _showAddResumeDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context))),
          child: Padding(
            padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Yangi Resume',
                  style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w600),
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Sarlavha',
                    labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
                    filled: true,
                    fillColor: AppColors.lightBlue.withAlpha(50),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)),
                ),
                SizedBox(height: Responsive.scaleHeight(20, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Bekor qilish', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
                    ),
                    SizedBox(width: Responsive.scaleWidth(10, context)),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          // Yangi resume qo'shish logikasi bu yerga qo'shiladi
                          Navigator.pop(context);
                          Get.snackbar('Muvaffaqiyat', 'Resume qo‘shildi', backgroundColor: AppColors.darkBlue, colorText: AppColors.white);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context))),
                        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(8, context)),
                      ),
                      child: Text('Saqlash', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int index) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context))),
        title: Text('O‘chirish', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(16, context))),
        content: Text('Rostdan ham ushbu resume-ni o‘chirmoqchimisiz?', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Yo‘q', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
          ),
          ElevatedButton(
            onPressed: () {
              // O'chirish logikasi bu yerga qo'shiladi
              Get.back();
              Get.snackbar('Muvaffaqiyat', 'Resume o‘chirildi', backgroundColor: AppColors.red, colorText: AppColors.white);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context))),
              padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(8, context)),
            ),
            child: Text('Ha', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))),
          ),
        ],
      ),
    );
  }
}