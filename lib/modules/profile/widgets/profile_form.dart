import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(label: 'Ism'.tr, hint: 'Ismingizni kiriting'.tr),
        SizedBox(height: Responsive.scaleHeight(16, context)),
        CustomTextField(label: 'Familya'.tr, hint: 'Familyangizni kiriting'.tr),
        SizedBox(height: Responsive.scaleHeight(16, context)),
        CustomTextField(label: 'Yosh (ixtiyoriy)'.tr, hint: 'Yoshingizni kiriting'.tr, keyboardType: TextInputType.number)
      ]
    );
  }
}
