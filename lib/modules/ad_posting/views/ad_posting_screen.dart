import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingScreen extends GetView<AdPostingController> {
  const AdPostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.apiController.fetchRegions(),
      builder: (context, regionSnapshot) {
        if (regionSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
        }
        if (regionSnapshot.hasError || !regionSnapshot.hasData || regionSnapshot.data!.isEmpty) {
          return Center(child: Text('Viloyatlar yuklanmadi', style: TextStyle(color: AppColors.lightGray)));
        }

        if (controller.regions.isEmpty) {
          controller.regions.value = regionSnapshot.data!;
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(context),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.titleController, 'E’lon sarlavhasi *', 'Masalan: Yangi ish imkoniyati'),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.contentController, 'Tavsif *', 'Tavsif yozing...', maxLines: 4),
              SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Expanded(child: _buildTextField(context, controller.salaryFromController, 'Oylik (dan)', '50000', keyboardType: TextInputType.number)),
                  SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(child: _buildTextField(context, controller.salaryToController, 'Oylik (gacha)', '70000', keyboardType: TextInputType.number))
                ]
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildDropdownField<int>(
                context,
                'Kategoriya *',
                controller.categories,
                controller.selectedCategory,
                LucideIcons.briefcase,
                    (value) => controller.selectedCategory.value = value ?? 1,
                isInt: true,
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildDropdownField<String>(
                context,
                'Viloyat *',
                controller.regions,
                controller.selectedRegionId,
                LucideIcons.map,
                    (value) {
                  if (value != null) {
                    controller.selectedRegionId.value = value;
                    controller.loadDistricts(int.parse(value));
                  }
                },
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              Obx(() {
                return controller.isLoadingDistricts.value
                    ? SizedBox(
                  height: AppDimensions.buttonHeight,
                  child: Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
                )
                    : _buildDropdownField<String>(
                  context,
                  'Tuman *',
                  controller.districts,
                  controller.selectedDistrictId,
                  LucideIcons.mapPin,
                      (value) => controller.selectedDistrictId.value = value ?? '0',
                );
              }),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.locationTitleController, 'Manzil', 'Masalan: Office Building'),
              SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(context, controller.latitudeController, 'Kenglik', '40.7128', keyboardType: TextInputType.number),
                  ),
                  SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: _buildTextField(context, controller.longitudeController, 'Uzunlik', '-74.006', keyboardType: TextInputType.number),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.phoneNumberController, 'Telefon raqami *', '+1234567890', keyboardType: TextInputType.phone),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.emailController, 'Email', 'example@email.com', keyboardType: TextInputType.emailAddress),
              SizedBox(height: AppDimensions.paddingLarge),
              _buildSubmitButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: controller.pickImage,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: Responsive.scaleHeight(150, context),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: controller.selectedImage.value == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.imagePlus,
                color: AppColors.lightBlue.withOpacity(0.7),
                size: Responsive.scaleWidth(40, context),
              ),
              SizedBox(height: AppDimensions.paddingSmall),
              Text(
                'Rasm yuklash',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.scaleFont(16, context),
                  color: AppColors.lightBlue.withOpacity(0.7),
                ),
              ),
            ],
          )
              : ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: Image.file(
              controller.selectedImage.value!,
              fit: BoxFit.cover,
              height: Responsive.scaleHeight(150, context),
              width: double.infinity,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.lightGray),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.7)),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.5)),
        filled: true,
        fillColor: AppColors.darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
        contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
      ),
    );
  }

  Widget _buildDropdownField<T>(
      BuildContext context,
      String label,
      RxList<dynamic> items,
      Rx<T> selectedValue,
      IconData icon,
      Function(T?) onChanged, {
        bool isInt = false,
      }) {
    return Obx(() {
      return DropdownButtonFormField2<T>(
        value: selectedValue.value,
        isExpanded: true,
        validator: (val) => val == null || (isInt && (val as int) == 0) || (!isInt && (val as String).isEmpty) ? '$label tanlanishi shart' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
          labelText: label,
          labelStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.7)),
          filled: true,
          fillColor: AppColors.darkBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
          ),
          contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: Responsive.scaleHeight(200, context),
          width: Responsive.scaleWidth(250, context),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [BoxShadow(color: AppColors.darkBlue.withAlpha(100), blurRadius: 5)],
          ),
          elevation: 4,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(LucideIcons.chevronDown, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
        ),
        style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
        items: items.asMap().entries.map((entry) {
          final item = entry.value;
          return DropdownMenuItem<T>(
            value: isInt ? (entry.key + 1) as T : item['id'].toString() as T,
            child: Text(
              isInt ? item.toString() : item['name'] ?? 'Noma’lum',
              style: TextStyle(fontSize: Responsive.scaleFont(14, context)),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text('Tanlang', style: TextStyle(color: AppColors.lightBlue.withOpacity(0.7), fontSize: Responsive.scaleFont(14, context))),
      );
    });
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: controller.submitAd,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
          elevation: 2,
        ),
        child: Text(
          'E’lonni yuborish',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: Responsive.scaleFont(16, context),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}