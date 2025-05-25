import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingScreen extends GetView<AdPostingController> {
  const AdPostingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E\'lon qo\'shish', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
      ),
      body: Center(
        child: Text(
          'E\'lon qo\'shish sahifasi (Placeholder)',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: Responsive.scaleFont(24, context),
              ),
        ),
      ),
    );
  }
}
