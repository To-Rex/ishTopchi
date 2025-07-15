import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/models/resumes_model.dart';
import '../../../core/services/show_toast.dart';

class CreateResumeController extends GetxController {
  final titleController = ''.obs;
  final contentController = ''.obs;
  final educationList = <Education>[].obs;
  final experienceList = <Experience>[].obs;
  final selectedFile = Rx<File?>(null);
  final isLoading = false.obs;
  final isEditing = false.obs;
  final resumeId = Rx<int?>(null);

  final ApiController apiController = Get.find<ApiController>();

  // Resume ma'lumotlarini yuklash (tahrirlash uchun)
  void loadResumeData(ResumesData? resume) {
    if (resume != null) {
      isEditing.value = true;
      resumeId.value = resume.id;
      titleController.value = resume.title ?? '';
      contentController.value = resume.content ?? '';
      educationList.assignAll(resume.education ?? []);
      experienceList.assignAll(resume.experience ?? []);
      selectedFile.value = null; // Faylni qayta yuklash kerak bo'lsa, bu o'zgartiriladi
    } else {
      isEditing.value = false;
      resumeId.value = null;
      titleController.value = '';
      contentController.value = '';
      educationList.clear();
      experienceList.clear();
      selectedFile.value = null;
    }
  }

  // Ta'lim qo'shish
  void addEducation() {
    educationList.add(Education());
  }

  // Tajriba qo'shish
  void addExperience() {
    experienceList.add(Experience());
  }

  // Ta'lim o'chirish
  void removeEducation(int index) {
    educationList.removeAt(index);
  }

  // Tajriba o'chirish
  void removeExperience(int index) {
    experienceList.removeAt(index);
  }

  // Fayl tanlash
  Future<void> pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedFile.value = File(pickedFile.path);
    }
  }

  // Validatsiya
  bool validateForm() {
    if (titleController.value.isEmpty) {
      ShowToast.show('Xatolik', 'Sarlavha kiritilishi shart', 3, 1);
      return false;
    }
    if (contentController.value.isEmpty) {
      ShowToast.show('Xatolik', 'Tavsif kiritilishi shart', 3, 1);
      return false;
    }
    return true;
  }

  // Resume yaratish yoki yangilash
  Future<void> saveResume() async {
    if (!validateForm()) return;

    isLoading.value = true;
    try {
      final educationData = educationList.map((edu) => {
        'degree': edu.degree,
        'field': edu.field,
        'institution': edu.institution,
        'period': edu.period,
      }).toList();

      final experienceData = experienceList.map((exp) => {
        'position': exp.position,
        'company': exp.company,
        'period': exp.period,
        'description': exp.description,
      }).toList();

      if (isEditing.value && resumeId.value != null) {
        // Resume yangilash
        await apiController.updateResume(
          resumeId: resumeId.value!,
          title: titleController.value,
          content: contentController.value,
          education: educationData,
          experience: experienceData,
          file: selectedFile.value,
        );
      } else {
        // Yangi resume yaratish
        await apiController.createResume(
          title: titleController.value,
          content: contentController.value,
          education: educationData,
          experience: experienceData,
          file: selectedFile.value,
        );
      }
      Get.back(); // Sahifadan chiqish
    } catch (e) {
      ShowToast.show('Xatolik', 'Resume saqlashda xato: $e', 3, 1);
    } finally {
      isLoading.value = false;
    }
  }
}