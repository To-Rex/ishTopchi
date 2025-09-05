import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  HelpCenterScreenState createState() => HelpCenterScreenState();
}

class HelpCenterScreenState extends State<HelpCenterScreen> with SingleTickerProviderStateMixin {
  final ProfileController profileController = Get.find<ProfileController>();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yordam markazi'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
        backgroundColor: AppColors.darkNavy,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)), onPressed: () => Get.back()),
        elevation: 0
      ),
      backgroundColor: AppColors.darkNavy,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.scaleWidth(10, context),
          vertical: Responsive.scaleHeight(12, context),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xush kelibsiz xabar (animatsiyali)
              SizeTransition(
                sizeFactor: _animation,
                child: _buildWelcomeSection(context),
              ),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // FAQ bo'limi
              _buildSectionTitle(context, 'Tez-tez so‘raladigan savollar'.tr),
              SizedBox(height: Responsive.scaleHeight(10, context)),
              _buildFaqItem(context, 'Qanday qilib ro‘yxatdan o‘taman?'.tr, 'Ro‘yxatdan o‘tish uchun "Kirish" tugmasini bosing va ko‘rsatmalarni bajaring.'.tr),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildFaqItem(context, 'Parolni qanday tiklayman?'.tr, 'Siz "Parolni unutdingizmi?" havolasini ishlatib parolni tiklashingiz mumkin.'.tr),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildFaqItem(context, 'Ilovada xatolik yuz berdi, nima qilish kerak?'.tr, 'Iltimos, ilova versiyasini yangilab ko‘ring yoki Qo‘llab-quvvatlashga murojaat qiling.'.tr),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Qo'llanmalar bo'limi
              _buildSectionTitle(context, 'Qo‘llanmalar'.tr),
              SizedBox(height: Responsive.scaleHeight(10, context)),
              _buildGuideItem(context, 'Ilova bilan tanishish'.tr, 'https://ishtopchi.uz/guide', () => _launchURL('https://ishtopchi.uz/guide')),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildGuideItem(context, 'Xususiyatlarni foydalanish'.tr, 'https://ishtopchi.uz/features', () => _launchURL('https://ishtopchi.uz/features')),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildGuideItem(context, 'Profilni sozlamoqchimisiz?'.tr, 'https://ishtopchi.uz/profile-setup', () => _launchURL('https://ishtopchi.uz/profile-setup')),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Biz bilan bog'lanish
              _buildSectionTitle(context, 'Biz bilan bog‘lanish'.tr),
              SizedBox(height: Responsive.scaleHeight(10, context)),
              _buildContactItem(context, Icons.phone, 'Telefon'.tr, '+998 90 123 45 67', () => _launchURL('tel:+998901234567')),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildContactItem(context, Icons.email, 'Email'.tr, 'support@ishtopchi.uz', () => _launchURL('mailto:support@ishtopchi.uz')),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildContactItem(context, Icons.telegram, 'Telegram'.tr, '@IshtopchiSupport', () => _launchURL('https://t.me/IshtopchiSupport')),
              SizedBox(height: Responsive.scaleHeight(16, context)),
              // Mualliflik
              Center(
                child: Text(
                  '© 2025 Ishtopchi. Barcha huquqlar himoyalangan.'.tr,
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(10, context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: Responsive.scaleHeight(16, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withAlpha(50),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'help-icon',
            child: Icon(Icons.help, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
          ),
          SizedBox(width: Responsive.scaleWidth(10, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xush kelibsiz!'.tr,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: Responsive.scaleFont(16, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                Text(
                  'Bu yerda siz ilova bilan ishlash bo‘yicha yordam topasiz. Savollaringiz uchun biz bilan bog‘laning.'.tr,
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(12, context),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(key: ValueKey<String>(title), title, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w600))
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(Responsive.scaleWidth(10, context)),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
        boxShadow: [BoxShadow(color: AppColors.darkNavy.withAlpha(50), blurRadius: 3, offset: Offset(0, 1))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(color: AppColors.lightBlue, fontSize: Responsive.scaleFont(12, context), fontWeight: FontWeight.w500)),
          SizedBox(height: Responsive.scaleHeight(4, context)),
          Text(answer, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(10, context)))
        ]
      )
    );
  }

  Widget _buildGuideItem(BuildContext context, String title, String detail, VoidCallback onTap) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
        child: Container(
          padding: EdgeInsets.all(Responsive.scaleWidth(10, context)),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
            boxShadow: [BoxShadow(color: AppColors.darkNavy.withAlpha(50), blurRadius: 3, offset: Offset(0, 1))]
          ),
          child: Row(
            children: [
              Icon(Icons.book, color: AppColors.lightBlue, size: Responsive.scaleFont(16, context)),
              SizedBox(width: Responsive.scaleWidth(8, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(12, context), fontWeight: FontWeight.w500)),
                    Text(detail, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(10, context)), maxLines: 1, overflow: TextOverflow.ellipsis)
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String title, String detail, VoidCallback onTap) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
        child: Container(
          padding: EdgeInsets.all(Responsive.scaleWidth(10, context)),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
            boxShadow: [BoxShadow(color: AppColors.darkNavy.withAlpha(50), blurRadius: 3, offset: Offset(0, 1))]
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.lightBlue, size: Responsive.scaleFont(16, context)),
              SizedBox(width: Responsive.scaleWidth(8, context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(12, context), fontWeight: FontWeight.w500)),
                    Text(detail, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(10, context)), maxLines: 1, overflow: TextOverflow.ellipsis)
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Xatolik'.tr, 'Havola ochilmadi'.tr, colorText: AppColors.white, backgroundColor: AppColors.red);
    }
  }

}