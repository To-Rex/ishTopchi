import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../controllers/api_controller.dart';

/// Telegram orqali kirishning birinchi qadami — telefon raqam.
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqam kiriting'.tr;
    }
    if (!RegExp(r'^\d{9}$').hasMatch(phoneFormatter.getUnmaskedText())) {
      return 'Format: 90 123 45 67';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cleanPhone = phoneFormatter.getUnmaskedText();
      debugPrint('Telefon raqam: $cleanPhone');
      ApiController().generateOtp(cleanPhone);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Telefon raqam'.tr,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              AppReveal(
                child: AppHeading(
                  title: 'Telefon raqam kiriting'.tr,
                  subtitle:
                      'Telegramdan ro‘yxatdan o‘tgan raqam bo‘lishi kerak'.tr,
                ),
              ),
              const SizedBox(height: 36),
              AppReveal(
                delay: const Duration(milliseconds: 70),
                child: _buildPhoneField(context),
              ),
              const SizedBox(height: 20),
              AppReveal(
                delay: const Duration(milliseconds: 120),
                child: AppButton(
                  label: 'Kodni yuborish'.tr,
                  filled: true,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Prefiks, hint va yozilgan raqam — hammasi shu bitta uslubdan
    // hosil qilinadi, shunda ular bir qatorda aniq tekislanadi va
    // yozish boshlanganda matn sakramaydi.
    final fieldStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      // Raqamlar bir xil kenglikda turadi — yozganda belgilar sakramaydi.
      fontFeatures: const [FontFeature.tabularFigures()],
      color: colors.onSurface,
    );

    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [phoneFormatter],
      style: fieldStyle,
      decoration: InputDecoration(
        hintText: '90 123 45 67',
        hintStyle: fieldStyle.copyWith(
          color: colors.onSurface.withValues(alpha: 0.42),
        ),
        prefixIcon: AppFieldPrefix(text: '+998', textStyle: fieldStyle),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        // Prefiks boʻlgani uchun chap chekka oʻsha prefiks ichida
        // beriladi — aks holda ikkala toʻldirish qoʻshilib, prefiks
        // raqamdan uzilib qoladi.
        contentPadding: const EdgeInsets.only(
          left: 0,
          right: 18,
          top: 17,
          bottom: 17,
        ),
      ),
      validator: _validatePhone,
      onChanged: (val) => setState(() {}),
    );
  }
}
