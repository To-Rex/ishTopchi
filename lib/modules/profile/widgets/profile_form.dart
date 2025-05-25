import 'package:flutter/material.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Ism',
          hint: 'Ismingizni kiriting',
        ),
        SizedBox(height: Responsive.scaleHeight(16, context)),
        CustomTextField(
          label: 'Familya',
          hint: 'Familyangizni kiriting',
        ),
        SizedBox(height: Responsive.scaleHeight(16, context)),
        CustomTextField(
          label: 'Yosh (ixtiyoriy)',
          hint: 'Yoshingizni kiriting',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
