import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Qidirish...',
                hintStyle: TextStyle(color: AppColors.lightBlue),
                filled: true,
                fillColor: AppColors.darkNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.scaleWidth(8, context)),
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.lightGray),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
