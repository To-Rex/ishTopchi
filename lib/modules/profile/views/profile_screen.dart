import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
      ),
      body: Center(
        child: Text(
          'Profil sahifasi (Placeholder)',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: Responsive.scaleFont(24, context),
              ),
        ),
      ),
    );
  }
}
