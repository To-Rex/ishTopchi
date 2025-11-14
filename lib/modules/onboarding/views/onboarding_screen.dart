import 'dart:io';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ishtopchi/config/theme/app_colors.dart';
import 'package:get/get.dart';
import '../../../common/widgets/bottom_sheets.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final OnboardingController controller = OnboardingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: AppColors.darkBlue, elevation: 0, actions: [IconButton(icon: const Icon(Icons.language, color: Color(0xFFE0E1DD), size: 24), onPressed: () => BottomSheets().showLanguageBottomSheet(), tooltip: 'Tilni o‘zgartirish'.tr)]),
      body: SafeArea( // Qurilma chetlarini hisobga olish
        child: Container(
          margin: EdgeInsets.only(bottom: Platform.isAndroid ? 50 : 0),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1B263B), Color(0xFF0D1B2A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: IntroductionScreen(
            pages: [
              PageViewModel(
                titleWidget: Text("Ishtopchi bilan ish toping!".tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFE0E1DD), shadows: [Shadow(blurRadius: 12, color: Colors.black45, offset: Offset(2, 2))])),
                bodyWidget: Text("Eng yaxshi ish e’lonlarini toping va o‘z karyerangizni boshlang.".tr, style: TextStyle(fontSize: 16, color: Color(0xFF778DA9), height: 1.5), textAlign: TextAlign.center),
                image: FadeTransition(opacity: _fadeAnimation, child: Icon(Icons.work_outline, size: 140, color: Color(0xFFE0E1DD))),
                decoration: PageDecoration(pageColor: Colors.transparent, bodyPadding: EdgeInsets.symmetric(horizontal: 24), imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15))
              ),
              PageViewModel(
                titleWidget: Text("E’lon joylashtiring".tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFE0E1DD), shadows: [Shadow(blurRadius: 12, color: Colors.black45, offset: Offset(2, 2))])),
                bodyWidget: Text("Ish beruvchi sifatida o‘z e’lonlaringizni osongina joylashtiring.".tr, style: TextStyle(fontSize: 16, color: Color(0xFF778DA9), height: 1.5), textAlign: TextAlign.center),
                image: FadeTransition(opacity: _fadeAnimation, child: Icon(Icons.post_add, size: 140, color: Color(0xFFE0E1DD))),
                decoration: PageDecoration(pageColor: Colors.transparent, bodyPadding: EdgeInsets.symmetric(horizontal: 24), imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15))
              ),
              PageViewModel(
                titleWidget: Text("Qulay interfeys".tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFE0E1DD), shadows: [Shadow(blurRadius: 12, color: Colors.black45, offset: Offset(2, 2))])),
                bodyWidget: Text("Zamonaviy dizayn va foydalanish uchun qulay platforma.".tr, style: TextStyle(fontSize: 16, color: Color(0xFF778DA9), height: 1.5), textAlign: TextAlign.center),
                image: FadeTransition(opacity: _fadeAnimation, child: Icon(Icons.phone_iphone, size: 140, color: Color(0xFFE0E1DD))),
                decoration: PageDecoration(pageColor: Colors.transparent, bodyPadding: EdgeInsets.symmetric(horizontal: 24), imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15))
              ),
              PageViewModel(
                titleWidget: Text("Xavfsiz kirish".tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFFE0E1DD), shadows: [Shadow(blurRadius: 12, color: Colors.black45, offset: Offset(2, 2))])),
                bodyWidget: Text("Google yoki Telegram orqali tez va xavfsiz ro‘yxatdan o‘ting.".tr, style: TextStyle(fontSize: 16, color: Color(0xFF778DA9), height: 1.5), textAlign: TextAlign.center),
                image: FadeTransition(opacity: _fadeAnimation, child: Icon(Icons.lock_outline, size: 140, color: Color(0xFFE0E1DD))),
                decoration: PageDecoration(pageColor: Colors.transparent, bodyPadding: EdgeInsets.symmetric(horizontal: 24), imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15))
              )
            ],
            done: Container(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              alignment: Alignment.center,
              constraints: BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(color: Color(0xFF415A77), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 14, offset: Offset(0, 4))]),
              child: Text("Boshlash".tr, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFE0E1DD)))
            ),
            onDone: controller.completeOnboarding,
            showSkipButton: true,
            skip: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              alignment: Alignment.center,
              constraints: BoxConstraints(minWidth: 200),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Color(0xFF778DA9), width: 1)),
              child: Text("O‘tkazib yuborish".tr, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 11, color: Color(0xFF778DA9), fontWeight: FontWeight.w600))
            ),
            next: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF415A77), boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))]),
              child: Icon(Icons.arrow_forward, color: Color(0xFFE0E1DD), size: 22)
            ),
            dotsDecorator: DotsDecorator(
              activeColor: AppColors.lightBlue,
              color: AppColors.lightBlue,
              size: Size(9, 9),
              activeSize: Size(16, 9),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              spacing: EdgeInsets.symmetric(horizontal: 5)
            ),
            globalBackgroundColor: Colors.transparent,
            animationDuration: 400
          )
        )
      )
    );
  }
}