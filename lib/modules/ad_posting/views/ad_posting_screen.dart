import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({super.key});

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen> with TickerProviderStateMixin {
  final AdPostingController controller = Get.find<AdPostingController>();
  late final AnimatedMapController _animatedMapController;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Har bir maydon uchun GlobalKey
  final _titleFieldKey = GlobalKey<FormFieldState>();
  final _contentFieldKey = GlobalKey<FormFieldState>();
  final _salaryFromFieldKey = GlobalKey<FormFieldState>();
  final _salaryToFieldKey = GlobalKey<FormFieldState>();
  final _categoryFieldKey = GlobalKey<FormFieldState>();
  final _regionFieldKey = GlobalKey<FormFieldState>();
  final _districtFieldKey = GlobalKey<FormFieldState>();
  final _locationTitleFieldKey = GlobalKey<FormFieldState>(); // Yangi kalit manzil matn maydoni uchun
  final _locationFieldKey = GlobalKey<FormFieldState>(); // Xarita maydoni uchun
  final _phoneFieldKey = GlobalKey<FormFieldState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    initialText: '+998 ',
  );

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqami kiritilishi shart';
    }
    if (!value.startsWith('+998') || phoneFormatter.getUnmaskedText().length != 9) {
      return 'Telefon raqami +998 bilan boshlanishi va 9 ta raqamdan iborat bo‘lishi kerak';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(mapController: controller.mapController, vsync: this);
    controller.phoneNumberController.text = '+998 ';
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _moveMap(LatLng point, double zoom) => _animatedMapController.animateTo(
    dest: point,
    zoom: zoom,
    duration: const Duration(milliseconds: 900),
  );

  // Xato maydoniga scroll qilish funksiyasi
  void _scrollToErrorField() {
    final List<GlobalKey<FormFieldState>> fieldKeys = [
      _titleFieldKey,
      _contentFieldKey,
      _salaryFromFieldKey,
      _salaryToFieldKey,
      _categoryFieldKey,
      _regionFieldKey,
      _districtFieldKey,
      _locationTitleFieldKey, // Yangi kalit qo‘shildi
      _locationFieldKey,
      _phoneFieldKey,
      _emailFieldKey,
    ];

    for (var key in fieldKeys) {
      if (key.currentState != null && !key.currentState!.isValid) {
        final context = key.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          break; // Birinchi xato topilganda to'xtatamiz
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.darkNavy,
    body: _buildBody(context),
  );

  Widget _buildBody(BuildContext context) => FutureBuilder<List<List<Map<String, dynamic>>>>(
    future: Future.wait([
      controller.apiController.fetchRegions(),
      controller.apiController.fetchCategories(),
    ]),
    builder: (context, snapshot) {
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
        controller: _scrollController,
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(context),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(
                context,
                controller.titleController,
                'E’lon sarlavhasi *',
                'Masalan: Yangi ish imkoniyati',
                maxLines: 1,
                keyboardType: TextInputType.text,
                validator: (value) => value == null || value.trim().isEmpty ? 'Sarlavha kiritilishi shart' : null,
                fieldKey: _titleFieldKey,
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(
                context,
                controller.contentController,
                'Tavsif *',
                'Tavsif yozing...',
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: (value) => value == null || value.trim().isEmpty ? 'Tavsif kiritilishi shart' : null,
                fieldKey: _contentFieldKey,
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      context,
                      controller.salaryFromController,
                      'Oylik (dan)',
                      '50000',
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      fieldKey: _salaryFromFieldKey,
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: _buildTextField(
                      context,
                      controller.salaryToController,
                      'Oylik (gacha)',
                      '70000',
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      fieldKey: _salaryToFieldKey,
                    ),
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
                validator: (value) => value == null || value == 0 ? 'Kategoriya tanlanishi shart' : null,
                isInt: true,
                fieldKey: _categoryFieldKey,
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
                validator: (value) => value == null || value.isEmpty ? 'Viloyat tanlanishi shart' : null,
                fieldKey: _regionFieldKey,
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              Obx(() => controller.isLoadingDistricts.value
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
                validator: (value) => value == null || value == '0' ? 'Tuman tanlanishi shart' : null,
                fieldKey: _districtFieldKey,
              )),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(
                context,
                controller.locationTitleController,
                'Manzil',
                'Masalan: Office Building',
                maxLines: 1,
                keyboardType: TextInputType.text,
                fieldKey: _locationTitleFieldKey, // Yangi kalit ishlatildi
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildMapPicker(context),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(
                context,
                controller.phoneNumberController,
                'Telefon raqami *',
                '+998 90 123 45 67',
                maxLines: 1,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneFormatter],
                validator: _validatePhone,
                fieldKey: _phoneFieldKey,
              ),
              SizedBox(height: AppDimensions.paddingMedium),
              _buildTextField(
                context,
                controller.emailController,
                'Email',
                'example@email.com',
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                fieldKey: _emailFieldKey,
              ),
              SizedBox(height: AppDimensions.paddingLarge),
              _buildSubmitButton(context),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildImagePicker(BuildContext context) => Obx(() => GestureDetector(
    onTap: controller.pickImage,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: Responsive.scaleHeight(150, context),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
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

  Widget _buildMapPicker(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Xaritada joyni tanlang *',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: Responsive.scaleFont(16, context),
          color: AppColors.lightBlue,
        ),
      ),
      SizedBox(height: AppDimensions.paddingSmall),
      Stack(
        children: [
          Container(
            height: Responsive.scaleHeight(300, context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              child: FormField<String>(
                key: _locationFieldKey,
                validator: (value) =>
                controller.latitudeController.text.isEmpty || controller.longitudeController.text.isEmpty
                    ? 'Joylashuv tanlanishi shart'
                    : null,
                builder: (formFieldState) => Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: _animatedMapController.mapController,
                        options: MapOptions(
                          initialCenter: controller.selectedLocation.value,
                          initialZoom: controller.currentZoom.value,
                          onTap: (tapPosition, point) {
                            controller.updateLocation(point, _moveMap);
                            formFieldState.didChange(point.toString());
                          },
                          onMapReady: () {
                            controller.isMapReady.value = true;
                            controller.getCurrentLocation(_moveMap);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.ishtopchi',
                            tileProvider: CachedTileProvider(),
                          ),
                          Obx(() => MarkerLayer(
                            markers: [
                              if (controller.currentLocation.value != null)
                                Marker(
                                  width: 40.0,
                                  height: 40.0,
                                  point: controller.currentLocation.value!,
                                  child: const Icon(
                                    LucideIcons.locateFixed, // Tuzatildi
                                    color: Colors.blue,
                                    size: 20.0,
                                  ),
                                ),
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: controller.selectedLocation.value,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 30.0,
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                    if (formFieldState.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          formFieldState.errorText!,
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: Responsive.scaleFont(12, context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: AppDimensions.paddingSmall,
            top: AppDimensions.paddingSmall,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.darkBlue,
                  onPressed: () => controller.zoomIn(_moveMap),
                  child: Icon(
                    LucideIcons.plus,
                    color: AppColors.lightGray,
                    size: Responsive.scaleFont(18, context),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.darkBlue,
                  onPressed: () => controller.zoomOut(_moveMap),
                  child: Icon(
                    LucideIcons.minus,
                    color: AppColors.lightGray,
                    size: Responsive.scaleFont(18, context),
                  ),
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
              onPressed: () => controller.getCurrentLocation(_moveMap),
              tooltip: 'Joriy joylashuvni aniqlash',
              child: Icon(
                LucideIcons.locate,
                color: Colors.blue,
                size: Responsive.scaleFont(20, context),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildTextField(
      BuildContext context,
      TextEditingController controller,
      String label,
      String hint, {
        int maxLines = 1,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
        GlobalKey<FormFieldState>? fieldKey,
      }) =>
      TextFormField(
        key: fieldKey,
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: AppColors.lightGray),
        validator: validator,
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
          errorStyle: TextStyle(
            color: AppColors.red,
            fontSize: Responsive.scaleFont(12, context),
          ),
        ),
      );

  Widget _buildDropdownField<T>(
      BuildContext context,
      String label,
      RxList<dynamic> items,
      Rx<T> selectedValue,
      IconData icon,
      Function(T?) onChanged, {
        String? Function(T?)? validator,
        bool isInt = false,
        GlobalKey<FormFieldState>? fieldKey,
      }) =>
      DropdownButtonFormField2<T>(
        key: fieldKey,
        value: selectedValue.value,
        isExpanded: true,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: AppColors.lightGray,
            size: Responsive.scaleFont(18, context),
          ),
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
          errorStyle: TextStyle(
            color: AppColors.red,
            fontSize: Responsive.scaleFont(12, context),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: Responsive.scaleHeight(200, context),
          width: Responsive.scaleWidth(250, context),
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(color: AppColors.darkBlue.withAlpha(100), blurRadius: 5),
            ],
          ),
          elevation: 4,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            LucideIcons.chevronDown,
            color: AppColors.lightGray,
            size: Responsive.scaleFont(18, context),
          ),
        ),
        style: TextStyle(
          color: AppColors.lightGray,
          fontSize: Responsive.scaleFont(14, context),
        ),
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
        hint: Text(
          'Tanlang',
          style: TextStyle(
            color: AppColors.lightBlue.withOpacity(0.7),
            fontSize: Responsive.scaleFont(14, context),
          ),
        ),
      );

  Widget _buildSubmitButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: AppDimensions.buttonHeight,
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          controller.submitAd();
        } else {
          _scrollToErrorField();
        }
      },
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