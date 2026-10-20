import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_brand.dart';
import '../controllers/otp_controller.dart';

/// Telegram orqali kirishning ikkinchi qadami — tasdiqlash kodi.
class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key, required this.phone});

  final String phone;

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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScreen(
      title: 'Tasdiqlash kodi'.tr,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            AppReveal(
              child: AppHeading(
                title: 'SMS orqali yuborilgan kodni kiriting'.tr,
                titleSize: 26,
              ),
            ),
            const SizedBox(height: 12),
            AppReveal(
              delay: const Duration(milliseconds: 50),
              child: Text(
                '+998 $phone',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Yoʻriqnoma kod maydonidan oldin turadi: foydalanuvchi
            // avval Telegramdan kodni olishi kerak.
            AppReveal(
              delay: const Duration(milliseconds: 100),
              child: _buildTelegramHint(theme, colors),
            ),
            const SizedBox(height: 30),
            AppReveal(
              delay: const Duration(milliseconds: 150),
              child: _buildPinField(context, colors),
            ),
            const SizedBox(height: 10),
            AppReveal(
              delay: const Duration(milliseconds: 200),
              child: _buildResend(colors),
            ),
          ],
        ),
      ),
    );
  }

  /// Olti xonali kod maydoni.
  ///
  /// Ranglari telefon raqam maydoni bilan bir xil manbadan olinadi.
  /// Xatolikda kontur va raqamlar qizaradi, silkinish animatsiyasi
  /// avvalgidek `errorCtrl` orqali keladi.
  Widget _buildPinField(BuildContext context, ColorScheme colors) {
    return Obx(() {
      final hasError = controller.isError.value;
      final field = AppBrand.fieldColors(colors, Theme.of(context).brightness);
      final borderColor = hasError ? colors.error : field.border;
      final selectedColor = hasError ? colors.error : field.focus;

      return PinCodeTextField(
        appContext: context,
        length: 6,
        controller: controller.pinTEC,
        errorAnimationController: controller.errorCtrl,
        keyboardType: TextInputType.number,
        animationType: AnimationType.fade,
        textStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: hasError ? colors.error : colors.onSurface,
        ),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(14),
          fieldHeight: 56,
          fieldWidth: 44,
          borderWidth: 1.2,
          activeColor: borderColor,
          inactiveColor: borderColor,
          selectedColor: selectedColor,
          activeFillColor: field.fill,
          inactiveFillColor: field.fill,
          selectedFillColor: field.fill,
        ),
        enableActiveFill: true,
        animationDuration: const Duration(milliseconds: 200),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        onChanged: (value) async {
          if (value.length == 6) {
            final ok = await ApiController().loginWithOtp(otp: value);
            if (!ok) {
              // qizarish + silkinish + tozalash + 3s dan keyin tiklash
              controller.triggerOtpError();
            }
          }
        },
      );
    });
  }

  /// Kodni qayta yuborish yoki qolgan vaqt.
  Widget _buildResend(ColorScheme colors) {
    return Obx(() {
      final available = controller.resendAvailable.value;

      return Align(
        child: TextButton(
          onPressed:
              available
                  ? () {
                    if (controller.resendAvailable.value) {
                      controller.resendCode(phone);
                    }
                  }
                  : () {},
          style: TextButton.styleFrom(
            foregroundColor:
                available
                    ? colors.onSurface
                    : colors.onSurface.withValues(alpha: 0.5),
          ),
          child: Text(
            available
                ? 'Kodni qayta yuborish'.tr
                : 'Qayta yuborish mumkin: ${controller.remainingSeconds.value}s',
          ),
        ),
      );
    });
  }

  /// Telegram kanalini ochadigan yordam qatori.
  Widget _buildTelegramHint(ThemeData theme, ColorScheme colors) {
    final radius = BorderRadius.circular(16);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: _openTelegram,
        borderRadius: radius,
        splashColor: colors.onSurface.withValues(alpha: 0.06),
        highlightColor: colors.onSurface.withValues(alpha: 0.03),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colors.onSurface.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.telegram,
                size: 18,
                color: colors.onSurface.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Telegramga kelgan kodni tekshirish uchun bu yerga bosing!'
                      .tr,
                  maxLines: 3,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13.5,
                    color: colors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_outward,
                size: 16,
                color: colors.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
