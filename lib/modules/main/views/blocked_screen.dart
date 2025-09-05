import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  BlockedScreenState createState() => BlockedScreenState();
}

class BlockedScreenState extends State<BlockedScreen> with SingleTickerProviderStateMixin {
  final FuncController funcController = Get.find<FuncController>();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isEmailTapped = false;
  bool _isPhoneTapped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String email) async {
    setState(() => _isEmailTapped = true);
    await Future.delayed(const Duration(milliseconds: 200), () => setState(() => _isEmailTapped = false));
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ShowToast.show('Xatolik'.tr, 'Email ochilmadi'.tr, 3, 1);
    }
  }

  Future<void> _launchPhone(String phone) async {
    setState(() => _isPhoneTapped = true);
    await Future.delayed(const Duration(milliseconds: 200), () => setState(() => _isPhoneTapped = false));
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ShowToast.show('Xatolik'.tr, 'Telefon ochilmadi'.tr, 3, 1);
    }
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius, context))),
        title: Text('Accountdan chiqish'.tr, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: Responsive.scaleFont(20, context), color: AppColors.red, fontWeight: FontWeight.bold),),
        content: Text('Chiqishdan so‘ng tizimga qayta kirish uchun qayta login qiling!'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightBlue, height: 1.5), textAlign: TextAlign.start,),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(overlayColor: AppColors.darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius, context))), padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(AppDimensions.paddingMedium, context), vertical: Responsive.scaleHeight(AppDimensions.paddingSmall, context))),
            child: Text('Bekor qilish'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightGray, fontWeight: FontWeight.w600))
          ),
          TextButton(
            onPressed: () async {
              await funcController.deleteToken();
              //funcController.userMe.value = null;
              Get.back();
              Get.offAllNamed('/login');
              ShowToast.show('Muvaffaqiyatli'.tr, 'Tizimdan chiqildi'.tr, 1, 1);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(AppDimensions.paddingMedium, context), vertical: Responsive.scaleHeight(AppDimensions.paddingSmall, context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius, context)))
            ),
            child: Text('Chiqish'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.white, fontWeight: FontWeight.w600))
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.debugScreenInfo(context);
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(Responsive.scalePadding(AppDimensions.paddingLarge, context)),
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bloklangan ikonkasi
                  ScaleTransition(scale: _pulseAnimation, child: Icon(LucideIcons.lock, size: Responsive.scaleFont(AppDimensions.iconSizeLarge * 0.8, context), color: AppColors.red)),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingLarge, context)),
                  // Asosiy sarlavha
                  Text('Hisobingiz bloklangan'.tr, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: Responsive.scaleFont(32, context), color: AppColors.lightGray, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                  // Tushuntirish matni
                  Text('Hisobingiz vaqtincha bloklangan. Batafsil ma’lumot olish uchun qo‘llab-quvvatlash xizmatiga murojaat qiling.'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(15, context), color: AppColors.lightBlue.withAlpha(180), height: 1.6), textAlign: TextAlign.center),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingLarge * 1.5, context)),
                  // Bog‘lanish ma’lumotlari
                  GestureDetector(
                      onTapDown: (_) => setState(() => _isEmailTapped = true),
                      onTapUp: (_) => _launchEmail('ishtopchi@gmail.com'),
                      onTapCancel: () => setState(() => _isEmailTapped = false),
                      child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: _isEmailTapped ? 0.95 : 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
                          child: Container(
                              margin: EdgeInsets.only(bottom: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                              padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(AppDimensions.paddingMedium, context), horizontal: Responsive.scaleWidth(AppDimensions.paddingLarge, context)),
                              decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius * 1.2, context)),
                                  boxShadow: [BoxShadow(color: AppColors.darkNavy, blurRadius: 8, offset: const Offset(0, 3))]
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.mail, size: Responsive.scaleFont(AppDimensions.iconSizeMedium, context), color: AppColors.lightGray),
                                    SizedBox(width: Responsive.scaleWidth(AppDimensions.paddingSmall, context)),
                                    Text('ishtopchi@gmail.com', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600))
                                  ]
                              )
                          )
                      )
                  ),
                  // Telefon karta
                  GestureDetector(
                      onTapDown: (_) => setState(() => _isPhoneTapped = true),
                      onTapUp: (_) => _launchPhone('+998123456789'),
                      onTapCancel: () => setState(() => _isPhoneTapped = false),
                      child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: _isPhoneTapped ? 0.95 : 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut)),
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(AppDimensions.paddingMedium, context), horizontal: Responsive.scaleWidth(AppDimensions.paddingLarge, context)),
                              decoration: BoxDecoration(
                                  color: AppColors.darkBlue,
                                  borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius * 1.2, context)),
                                  boxShadow: [BoxShadow(color: AppColors.darkNavy, blurRadius: 8, offset: const Offset(0, 3))]
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.phone, size: Responsive.scaleFont(AppDimensions.iconSizeMedium, context), color: AppColors.lightGray),
                                    SizedBox(width: Responsive.scaleWidth(AppDimensions.paddingSmall, context)),
                                    Text('+998 99 534 03 13', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightBlue, fontWeight: FontWeight.w600))
                                  ]
                              )
                          )
                      )
                  ),
                  //log out button
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingLarge, context)),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(AppDimensions.paddingLarge, context), vertical: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(AppDimensions.cardRadius, context))),
                      overlayColor: AppColors.red
                    ),
                    onPressed: () => _showLogoutDialog(),
                    child: Text('Chiqish'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.red, fontWeight: FontWeight.w600))
                  )
                ]
              )
            )
          )
        )
      )
    );
  }
}