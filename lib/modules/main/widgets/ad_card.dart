import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class AdCard extends StatelessWidget {
  const AdCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlue,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'E\'lon (Placeholder)',
              style: TextStyle(
                fontSize: Responsive.scaleFont(18, context),
                color: AppColors.lightGray,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            Text(
              'Tavsif...',
              style: TextStyle(
                fontSize: Responsive.scaleFont(14, context),
                color: AppColors.lightBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
