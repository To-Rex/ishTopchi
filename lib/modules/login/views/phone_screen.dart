import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../config/theme/app_colors.dart';
import 'otp_verification_screen.dart';

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
    filter: { "#": RegExp(r'[0-9]') },
  );

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqam kiriting';
    }
    if (!RegExp(r'^\d{9}$').hasMatch(phoneFormatter.getUnmaskedText())) {
      return 'Format: 90 123 45 67';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cleanPhone = '+998${phoneFormatter.getUnmaskedText()}';
      debugPrint('Telefon raqam: $cleanPhone');
      Get.to(() => OtpVerificationScreen(phone: cleanPhone), transition: Transition.fadeIn);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: Text(
            'Telefon raqam',
            style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone_android, size: 60, color: AppColors.lightBlue),
                  const SizedBox(height: 24),
                  Text(
                    'Telefon raqam kiriting',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Telegramdan ro‘yxatdan o‘tgan raqam bo‘lishi kerak',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneFormatter],
                    style: const TextStyle(fontSize: 16, color: AppColors.white),
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 6),
                        child: Text('+998', style: TextStyle(fontSize: 16, color: AppColors.white)),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: '90 123 45 67',
                      hintStyle: const TextStyle(color: AppColors.lightBlue),
                      filled: true,
                      fillColor: AppColors.darkBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    validator: _validatePhone,
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.midBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _submit,
                      child: const Text('Kodni yuborish', style: TextStyle(fontSize: 16, color: AppColors.white)),
                    ),
                  ),
                  SizedBox(height: 150)
                ]
              )
            )
          )
        )
      )
    );
  }
}