import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/models/resumes_model.dart';
import '../../../core/utils/responsive.dart';
import 'create_resume_screen.dart';
import '../controllers/create_resume_controller.dart';

class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key});

  @override
  MyResumesScreenState createState() => MyResumesScreenState();
}

class MyResumesScreenState extends State<MyResumesScreen> {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();

  @override
  void initState() {
    super.initState();
    // CreateResumeController ni yaratish
    Get.put(CreateResumeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiController.fetchMeResumes(page: 1, limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(25, context)),
          onPressed: () => Get.back(),
        ),
        title: Text('Mening Rezumelarim', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(20, context), fontWeight: FontWeight.bold)),
      ),
      backgroundColor: AppColors.darkNavy,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Qo'shish tugmasi
            ElevatedButton(
              onPressed: () => Get.to(() => CreateResumeScreen()),
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
              child: Obx(() {
                if (funcController.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
                } else if (funcController.resumes.isEmpty) {
                  return Center(
                    child: Text(
                      'Rezumelar mavjud emas',
                      style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: funcController.resumes.length,
                  itemBuilder: (context, index) {
                    final resume = funcController.resumes[index];
                    return _buildResumeItem(context, resume, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeItem(BuildContext context, ResumesData resume, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.scaleHeight(12, context)),
      child: GestureDetector(
        onTap: () => Get.to(() => CreateResumeScreen(resume: resume)),
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
            leading: Icon(Icons.description, color: AppColors.lightBlue, size: Responsive.scaleFont(35, context)),
            title: Text(
              resume.title ?? 'Noma’lum',
              style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Yaratilgan sana: ${resume.createdAt?.substring(0, 10) ?? 'Noma’lum'}',
              style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent, size: Responsive.scaleFont(25, context)),
              onPressed: () => _confirmDelete(resume.id, index),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int? resumeId, int index) {
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
            onPressed: () async {
              if (resumeId != null) {
                await apiController.deleteResume(resumeId);
                Get.back();
              }
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