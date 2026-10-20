import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';

/// Bloklangan hisob ekrani.
class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  BlockedScreenState createState() => BlockedScreenState();
}

class BlockedScreenState extends State<BlockedScreen>
    with SingleTickerProviderStateMixin {
  final FuncController funcController = Get.find<FuncController>();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    // Ilgari 1.0 → 1.15 edi va tez takrorlanardi — juda diqqatni
    // tortardi. Endi sekinroq va yumshoqroq nafas oladi.
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ShowToast.show('Xatolik'.tr, 'Email ochilmadi'.tr, 3, 1);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ShowToast.show('Xatolik'.tr, 'Telefon ochilmadi'.tr, 3, 1);
    }
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Accountdan chiqish'.tr,
              style: theme.textTheme.titleLarge?.copyWith(color: AppColors.red),
            ),
            content: Text(
              'Chiqishdan so‘ng tizimga qayta kirish uchun qayta login qiling!'
                  .tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Bekor qilish'.tr),
              ),
              FilledButton(
                onPressed: () async {
                  await funcController.deleteToken();
                  //funcController.userMe.value = null;
                  //Get.back();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  Get.offAllNamed('/login');
                  ShowToast.show(
                    'Muvaffaqiyatli'.tr,
                    'Tizimdan chiqildi'.tr,
                    1,
                    1,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusControl),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: Text('Chiqish'.tr),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bloklangan belgisi
                AppReveal(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.red.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.lock,
                        size: 42,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Asosiy sarlavha
                AppReveal(
                  delay: const Duration(milliseconds: 90),
                  child: Text(
                    'Hisobingiz bloklangan'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 12),
                // Tushuntirish matni
                AppReveal(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    'Hisobingiz vaqtincha bloklangan. Batafsil ma’lumot olish uchun qo‘llab-quvvatlash xizmatiga murojaat qiling.'
                        .tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppReveal(
                  delay: const Duration(milliseconds: 210),
                  child: AppTile(
                    icon: LucideIcons.mail,
                    title: 'Email'.tr,
                    subtitle: 'ishtopchi@gmail.com',
                    onTap: () => _launchEmail('ishtopchi@gmail.com'),
                  ),
                ),
                AppReveal(
                  delay: const Duration(milliseconds: 250),
                  child: AppTile(
                    icon: LucideIcons.phone,
                    title: 'Telefon'.tr,
                    subtitle: '+998 99 534 03 13',
                    onTap: () => _launchPhone('+998770500125'),
                  ),
                ),
                const SizedBox(height: 18),
                AppReveal(
                  delay: const Duration(milliseconds: 300),
                  child: AppButton(
                    label: 'Chiqish'.tr,
                    leading: const Icon(LucideIcons.logOut),
                    onPressed: _showLogoutDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
