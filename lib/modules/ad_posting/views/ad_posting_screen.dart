import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingScreen extends GetView<AdPostingController> {
  const AdPostingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppColors.darkNavy, body: _buildBody(context));

  Widget _buildBody(BuildContext context) => FutureBuilder<List<List<Map<String, dynamic>>>>(future: Future.wait([
        controller.apiController.fetchRegions(),
        controller.apiController.fetchCategories(),
      ]), builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Ma’lumotlar yuklanmadi', style: TextStyle(color: AppColors.lightGray)));
        }

        final regions = snapshot.data![0];
        final categories = snapshot.data![1];
        if (controller.regions.isEmpty) {
          controller.regions.assignAll(regions);
        }
        if (controller.categories.isEmpty) {
          controller.categories.assignAll(categories);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(context),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.titleController, 'E’lon sarlavhasi *', 'Masalan: Yangi ish imkoniyati', maxLines: 1, keyboardType: TextInputType.text),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.contentController, 'Tavsif *', 'Tavsif yozing...', maxLines: 4, keyboardType: TextInputType.multiline),
              SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(context, controller.salaryFromController, 'Oylik (dan)', '50000', maxLines: 1, keyboardType: TextInputType.number),
                  ),
                  SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: _buildTextField(context, controller.salaryToController, 'Oylik (gacha)', '70000', maxLines: 1, keyboardType: TextInputType.number),
                  ),
                ],
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
                  child: const Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
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
              _buildTextField(context, controller.locationTitleController, 'Manzil', 'Masalan: Office Building', maxLines: 1, keyboardType: TextInputType.text),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildMapPicker(context),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.phoneNumberController, 'Telefon raqami *', '+998901234567', maxLines: 1, keyboardType: TextInputType.phone),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(context, controller.emailController, 'Email', 'example@email.com', maxLines: 1, keyboardType: TextInputType.emailAddress),
              SizedBox(height: AppDimensions.paddingLarge),
              _buildSubmitButton(context),
            ],
          ),
        );
      },);

  Widget _buildImagePicker(BuildContext context) => Obx(() => GestureDetector(
        onTap: controller.pickImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: Responsive.scaleHeight(150, context),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                size: Responsive.scaleFont(40, context),
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
      ));

  Widget _buildMapPicker(BuildContext context) => Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xaritada joyni tanlang', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightBlue)),
          SizedBox(height: AppDimensions.paddingSmall),
          Stack(
            children: [
              Container(
                height: Responsive.scaleHeight(300, context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  child: FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      initialCenter: controller.selectedLocation.value,
                      initialZoom: controller.currentZoom.value,
                      onTap: (tapPosition, point) {
                        controller.updateLocation(point);
                      },
                      onMapReady: () {
                        controller.isMapReady.value = true;
                        controller.getCurrentLocation();
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.ishtopchi',
                        tileBuilder: (context, widget, tile) {
                          print('Tile yuklanmoqda: ${tile.imageInfo?.toString()}');
                          return widget;
                        }
                      ),
                      MarkerLayer(
                        markers: [
                          if (controller.currentLocation.value != null)
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: controller.currentLocation.value!,
                              child: const Icon(LucideIcons.locateFixed, color: Colors.blue, size: 30.0)
                            ),
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: controller.selectedLocation.value,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 30.0)
                          )
                        ]
                      )
                    ]
                  )
                )
              ),
              Positioned(
                right: AppDimensions.paddingSmall,
                top: AppDimensions.paddingSmall,
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.darkBlue,
                      onPressed: controller.zoomIn,
                      child: Icon(LucideIcons.plus, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
                    ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    FloatingActionButton(
                      mini: true,
                      backgroundColor: AppColors.darkBlue,
                      onPressed: controller.zoomOut,
                      child: Icon(LucideIcons.minus, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: AppDimensions.paddingSmall,
                bottom: AppDimensions.paddingSmall,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.darkBlue,
                  onPressed: controller.getCurrentLocation,
                  child: Icon(LucideIcons.locate, color: Colors.blue, size: Responsive.scaleFont(20, context)),
                  tooltip: 'Joriy joylashuvni aniqlash'
                )
              )
            ]
          )
        ]
      ));

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, String hint, {int maxLines = 1, TextInputType? keyboardType}) =>
     TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.lightGray),
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
          borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.5),
        ),
        contentPadding: EdgeInsets.all(AppDimensions.paddingMedium),
      ),
    );

  Widget _buildDropdownField<T>(BuildContext context, String label, RxList<dynamic> items, Rx<T> selectedValue, IconData icon, Function(T?) onChanged, {bool isInt = false}) => Obx(() => DropdownButtonFormField2<T>(
        value: selectedValue.value,
        isExpanded: true,
        validator: (value) => value == null || (isInt && (value as int) == 0) || (!isInt && (value as String).isEmpty) ? '$label tanlanishi shart' : null,
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
            borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.5),
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
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: isInt ? item['id'] as T : item['id'].toString() as T,
            child: Text(
              item['title'] ?? item['name'] ?? 'Noma’lum',
              style: TextStyle(fontSize: Responsive.scaleFont(14, context)),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        hint: Text('Tanlang', style: TextStyle(color: AppColors.lightBlue.withOpacity(0.7), fontSize: Responsive.scaleFont(14, context))),
      ));

  Widget _buildSubmitButton(BuildContext context) => SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        child: ElevatedButton(
          onPressed: controller.submitAd,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius)),
              elevation: 2
          ),
          child: Text('E’lonni yuborish', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: Responsive.scaleFont(16, context), color: AppColors.white))
        )
      );

}