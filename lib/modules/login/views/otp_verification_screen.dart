import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/text_small.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../controllers/otp_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String phone;

  OtpVerificationScreen({super.key, required this.phone});

  final OtpController controller = Get.put(OtpController());

  Future<void> _openTelegram() async {
    final Uri url = Uri.parse("https://t.me/VerificationCodes");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Telegramni ochib bo‘lmadi!';
    }
  }

  @override
  Widget build(BuildContext context) {
    String otpCode = '';
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            'Tasdiqlash kodi'.tr,
            style: TextStyle(color: AppColors.textColor),
          ),
          backgroundColor: AppColors.backgroundColor,
          foregroundColor: AppColors.textColor,
          elevation: 0,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 60,
                    color: AppColors.iconColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tasdiqlash kodi'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SMS orqali yuborilgan kodni kiriting'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '+998 $phone',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textColor),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _openTelegram,
                    child: Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.telegram, color: AppColors.iconColor),
                          const SizedBox(width: 16),
                          // MUHIM: matnni Expanded bilan o'rab, o'ralishiga ruxsat beramiz
                          Expanded(
                            child: TextSmall(
                              text:
                                  'Telegramga kelgan kodni tekshirish uchun bu yerga bosing!'
                                      .tr,
                              color: AppColors.textColor,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // OtpVerificationScreen ichidagi o'zgarishlar

                  // 1) PinCodeTextField blokini almashtiring:
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: controller.pinTEC, // <— qo‘shildi
                        errorAnimationController:
                            controller.errorCtrl, // <— qo‘shildi
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        textStyle: TextStyle(
                          fontSize: 20,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 50,
                          fieldWidth: 42,
                          // Ranglarni xatolik holatiga qarab boshqaramiz:
                          activeFillColor:
                              controller.isError.value
                                  ? Colors.red
                                  : AppColors.cardColor,
                          inactiveFillColor:
                              controller.isError.value
                                  ? Colors.red.withOpacity(0.85)
                                  : AppColors.cardColor,
                          selectedFillColor:
                              controller.isError.value
                                  ? Colors.redAccent
                                  : AppColors.primaryColor,
                          activeColor: Colors.transparent,
                          inactiveColor: Colors.transparent,
                          selectedColor:
                              controller.isError.value
                                  ? Colors.redAccent
                                  : AppColors.primaryColor,
                        ),
                        animationDuration: const Duration(milliseconds: 200),
                        enableActiveFill: true,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        onChanged: (value) async {
                          if (value.length == 6) {
                            final ok = await ApiController().loginWithOtp(
                              otp: value,
                            );
                            if (!ok) {
                              controller
                                  .triggerOtpError(); // <— qizarish + shake + clear + 3s tiklash
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  /*Container(
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
                  ),*/
                  Obx(
                    () =>
                        controller.resendAvailable.value
                            ? TextButton(
                              onPressed: () {
                                if (controller.resendAvailable.value) {
                                  controller.resendCode(phone);
                                }
                              },
                              child: Text(
                                controller.resendAvailable.value
                                    ? 'Kodni qayta yuborish'.tr
                                    : '',
                                style: TextStyle(
                                  color:
                                      controller.resendAvailable.value
                                          ? AppColors.iconColor
                                          : Colors.grey.shade600,
                                ),
                              ),
                            )
                            : TextButton(
                              onPressed: () {},
                              child: Text(
                                'Qayta yuborish mumkin: ${controller.remainingSeconds.value}s',
                                style: TextStyle(color: AppColors.iconColor),
                              ),
                            ),
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
