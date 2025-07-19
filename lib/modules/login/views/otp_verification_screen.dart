import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/otp_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phone;

  OtpVerificationScreen({super.key, required this.phone});

  final OtpController controller = Get.put(OtpController());

  @override
  Widget build(BuildContext context) {
    String otpCode = '';

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: Text('Tasdiqlash kodi', style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: AppColors.white
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 60, color: AppColors.lightBlue),
                const SizedBox(height: 24),
                Text(
                  'Tasdiqlash kodi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'SMS orqali yuborilgan kodni kiriting',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '+998 $phone',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightGray,
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child:  PinCodeTextField(
                     length: 6,
                     keyboardType: TextInputType.number,
                     animationType: AnimationType.fade,
                     textStyle: const TextStyle(fontSize: 20, color: AppColors.white, fontWeight: FontWeight.bold),
                     pinTheme: PinTheme(
                       shape: PinCodeFieldShape.box,
                       borderRadius: BorderRadius.circular(10),
                       fieldHeight: 50,
                       fieldWidth: 42,
                       activeFillColor: AppColors.darkBlue,
                       inactiveFillColor: AppColors.darkBlue,
                       selectedFillColor: AppColors.midBlue,
                       activeColor: Colors.transparent,
                       inactiveColor: Colors.transparent,
                       selectedColor: AppColors.midBlue,
                     ),
                     animationDuration: const Duration(milliseconds: 200),
                     enableActiveFill: true,
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     onChanged: (value) {
                       otpCode = value;
                       if (value.length == 6) {
                         ApiController().loginWithOtp(otp: value);
                       }
                     },
                     appContext: context
                 )
                ),
                Obx(() => controller.resendAvailable.value ? TextButton(
                  onPressed: () {
                    if (controller.resendAvailable.value) {
                      controller.resendCode(phone);
                    }
                  },
                  child: Text(controller.resendAvailable.value ? 'Kodni qayta yuborish' : '', style: TextStyle(color: controller.resendAvailable.value ? AppColors.lightBlue : Colors.grey.shade600))
                ) : TextButton(
                  onPressed: () {},
                  child: Text('Qayta yuborish mumkin: ${controller.remainingSeconds.value}s', style: const TextStyle(color: AppColors.lightBlue))
                )),
                SizedBox(height: 150)
              ]
            )
          )
        )
      )
    );
  }
}