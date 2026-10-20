import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/custom_text_field.dart';

/// Profil maʼlumotlarining oddiy shakli.
///
/// Maydonlarning bezagi mavzudagi `inputDecorationTheme` dan keladi.
class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(label: 'Ism'.tr, hint: 'Ismingizni kiriting'.tr),
        const SizedBox(height: 14),
        CustomTextField(label: 'Familya'.tr, hint: 'Familyangizni kiriting'.tr),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'Yosh (ixtiyoriy)'.tr,
          hint: 'Yoshingizni kiriting'.tr,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
