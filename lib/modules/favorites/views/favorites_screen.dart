import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saqlanganlar', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
      ),
      body: Center(
        child: Text(
          'Saqlanganlar sahifasi (Placeholder)',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: Responsive.scaleFont(24, context),
              ),
        ),
      ),
    );
  }
}
