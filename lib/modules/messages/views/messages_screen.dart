import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/messages_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xabarlar', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
      ),
      body: Center(
        child: Text(
          'Xabarlar sahifasi (Placeholder)',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: Responsive.scaleFont(24, context),
              ),
        ),
      ),
    );
  }
}
