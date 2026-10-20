import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../common/widgets/success_notification.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({super.key});

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen>
    with TickerProviderStateMixin {
  final AdPostingController controller = Get.find<AdPostingController>();
  final FuncController funcController = Get.find<FuncController>();
  final ThemeController themeController = Get.find<ThemeController>();
  late final AnimatedMapController _animatedMapController;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _jobTypeFieldKey = GlobalKey<FormFieldState>();
  final _employmentTypeFieldKey = GlobalKey<FormFieldState>();

  // Har bir maydon uchun GlobalKey
  final _titleFieldKey = GlobalKey<FormFieldState>();
  final _contentFieldKey = GlobalKey<FormFieldState>();
  final _salaryFromFieldKey = GlobalKey<FormFieldState>();
  final _salaryToFieldKey = GlobalKey<FormFieldState>();
  final _categoryFieldKey = GlobalKey<FormFieldState>();
  final _regionFieldKey = GlobalKey<FormFieldState>();
  final _districtFieldKey = GlobalKey<FormFieldState>();
  final _locationTitleFieldKey =
      GlobalKey<FormFieldState>(); // Yangi kalit manzil matn maydoni uchun
  final _locationFieldKey = GlobalKey<FormFieldState>(); // Xarita maydoni uchun
  final _phoneFieldKey = GlobalKey<FormFieldState>();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  final phoneFormatter = MaskTextInputFormatter(
    mask: '+998 ## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    initialText: '+998 ',
  );

  final List<Map<String, String>> jobTypes = [
    {'value': '', 'title': 'Tanlang'.tr},
    {'value': 'FULL_TIME', 'title': 'To‘liq ish kuni'.tr},
    {'value': 'TEMPORARY', 'title': 'Vaqtinchalik ish'.tr},
    {'value': 'REMOTE', 'title': 'Masofaviy ish'.tr},
    {'value': 'DAILY', 'title': 'Kunlik ish'.tr},
    {'value': 'PROJECT_BASED', 'title': 'Loyihaviy asosda ish'.tr},
    {'value': 'INTERNSHIP', 'title': 'Amaliyot (stajirovka)'.tr},
  ];

  final List<Map<String, String>> employmentTypes = [
    {'value': '', 'title': 'Tanlang'.tr},
    {'value': 'FULL_TIME', 'title': 'To‘liq stavka'.tr},
    {'value': 'PART_TIME', 'title': 'Yarim stavka'.tr},
    {'value': 'SHIFT_BASED', 'title': 'Smenali ish jadvali'.tr},
    {'value': 'FLEXIBLE', 'title': 'Moslashuvchan ish vaqti'.tr},
    {'value': 'REGULAR_SCHEDULE', 'title': 'Doimiy ish jadvali'.tr},
  ];

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon raqami kiritilishi shart'.tr;
    }
    if (!value.startsWith('+998') ||
        phoneFormatter.getUnmaskedText().length != 9) {
      return 'Telefon raqami +998 bilan boshlanishi va 9 ta raqamdan iborat bo‘lishi kerak'
          .tr;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(
      mapController: controller.mapController,
      vsync: this,
    );
    controller.phoneNumberController.text = '+998 ';

    // Listen for submission success
    ever(controller.submissionSuccess, (bool success) {
      if (success) {
        // Show success notification
        SuccessNotificationOverlay.show(
          context,
          onDismiss: () {
            // Navigate to HomePage after animation completes
            funcController.setBarIndex(0);
          },
        );
        // Reset success state
        controller.submissionSuccess.value = false;
      }
    });
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
      _locationTitleFieldKey,
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
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AppContentWidth(
      child:
          funcController.getToken() == null || funcController.getToken() == ''
              ? NotLogged()
              : _buildBody(context),
    ),
  );

  Widget _buildBody(BuildContext context) => Obx(() {
    if (controller.regions.isEmpty || controller.categories.isEmpty) {
      // Birinchi load da, agar empty bo'lsa loading yoki xato ko'rsat
      return Center(
        child:
            controller.isLoadingDistricts.value
                ? CircularProgressIndicator(color: AppColors.iconColor)
                : Text(
                  'Ma’lumotlar yuklanmadi'.tr,
                  style: TextStyle(color: AppColors.textColor),
                ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      // "Joylashtirish" tugmasi pastki suzuvchi panel ostida qolmasin.
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium + MediaQuery.paddingOf(context).bottom,
      ),
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
              '${'E’lon sarlavhasi'.tr} *'.tr,
              'Masalan: Shirkat nomi'.tr,
              maxLines: 1,
              keyboardType: TextInputType.text,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Sarlavha kiritilishi shart'.tr
                          : null,
              fieldKey: _titleFieldKey,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildTextField(
              context,
              controller.contentController,
              '${'Tavsif'.tr} *'.tr,
              'Tavsif yozing...'.tr,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Tavsif kiritilishi shart'.tr
                          : null,
              fieldKey: _contentFieldKey,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    controller.salaryFromController,
                    'Oylik (dan)'.tr,
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
                    'Oylik (gacha)'.tr,
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
              '${'Kategoriya'.tr} *',
              controller.categories,
              controller.selectedCategory,
              LucideIcons.briefcase,
              (value) => controller.selectedCategory.value = value,
              validator:
                  (value) =>
                      value == null ? 'Kategoriya tanlanishi shart'.tr : null,
              isInt: true,
              fieldKey: _categoryFieldKey,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildDropdownField<String>(
              context,
              '${'Viloyat'.tr} *',
              controller.regions,
              controller.selectedRegionId,
              LucideIcons.map,
              (value) {
                controller.selectedRegionId.value = value;
                if (value != null) {
                  controller.loadDistricts(int.parse(value));
                } else {
                  controller.districts.value = [
                    {'id': '0', 'name': 'Tanlang'.tr},
                  ];
                  controller.selectedDistrictId.value = null;
                }
              },
              validator:
                  (value) =>
                      value == null ? 'Viloyat tanlanishi shart'.tr : null,
              fieldKey: _regionFieldKey,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            Obx(
              () =>
                  controller.isLoadingDistricts.value
                      ? SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.iconColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                      : _buildDropdownField<String>(
                        context,
                        '${'Tuman'.tr} *',
                        controller.districts,
                        controller.selectedDistrictId,
                        LucideIcons.mapPin,
                        (value) => controller.selectedDistrictId.value = value,
                        validator:
                            (value) =>
                                value == null
                                    ? 'Tuman tanlanishi shart'.tr
                                    : null,
                        fieldKey: _districtFieldKey,
                      ),
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildTextField(
              context,
              controller.locationTitleController,
              'Manzil'.tr,
              'Masalan: Office Building'.tr,
              maxLines: 1,
              keyboardType: TextInputType.text,
              fieldKey: _locationTitleFieldKey,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildDropdownJobType<String>(
              context,
              'Ish turi'.tr,
              jobTypes,
              controller.selectedJobType,
              LucideIcons.briefcase,
              (value) => controller.selectedJobType.value = value ?? '',
              fieldKey: _jobTypeFieldKey,
            ),
            /*SizedBox(height: AppDimensions.paddingMedium),
            _buildDropdownJobType<String>(
              context,
              'Bandlik turi'.tr,
              employmentTypes,
              controller.selectedEmploymentType,
              LucideIcons.clock,
              (value) => controller.selectedEmploymentType.value = value ?? '',
              fieldKey: _employmentTypeFieldKey,
            ),*/
            SizedBox(height: AppDimensions.paddingMedium),
            _buildMapPicker(context),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildTextField(
              context,
              controller.phoneNumberController,
              '${'Telefon raqami'.tr} *',
              '+998 99 534 03 13',
              maxLines: 1,
              keyboardType: TextInputType.phone,
              inputFormatters: [phoneFormatter],
              validator: _validatePhone,
              fieldKey: _phoneFieldKey,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            _buildTextField(
              context,
              controller.emailController,
              'Email'.tr,
              'torex.amaki@gmail.com',
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
  });

  Widget _buildDropdownJobType<T>(
    BuildContext context,
    String label,
    List<dynamic> items,
    Rx<T?> selectedValue,
    IconData icon,
    Function(T?) onChanged, {
    String? Function(T?)? validator,
    bool isInt = false,
    GlobalKey<FormFieldState>? fieldKey,
  }) => DropdownButtonFormField2<T>(
    key: fieldKey,
    value: selectedValue.value,
    isExpanded: true,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, size: 18),
      labelText: label,
    ),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 240,
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      offset: const Offset(0, -6),
    ),
    iconStyleData: IconStyleData(
      icon: Icon(
        LucideIcons.chevronDown,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    ),
    style: Theme.of(context).textTheme.bodyMedium,
    items:
        items
            .map(
              (item) => DropdownMenuItem<T>(
                value: isInt ? item['id'] as T : item['value'] as T,
                child: Text(
                  item['title'] ?? item['name'] ?? 'Noma’lum'.tr,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
    onChanged: onChanged,
    hint: Text(
      'Tanlang'.tr,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42),
      ),
    ),
  );

  /// Surat tanlash. Surat qoʻyilmaganda — konturli boʻsh maydon.
  Widget _buildImagePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return Obx(() {
      final image = controller.selectedImage.value;

      return Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.pickImage,
          child: Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color:
                    image != null
                        ? colors.primary.withValues(alpha: 0.35)
                        : colors.onSurface.withValues(alpha: 0.12),
                width: image != null ? 1.4 : 1.2,
              ),
            ),
            child:
                image == null
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.imagePlus,
                            size: 23,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Surat yuklash'.tr,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    )
                    : Image.file(image, fit: BoxFit.cover),
          ),
        ),
      );
    });
  }

  Widget _buildMapPicker(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSectionLabel(text: '${'Xaritada joyni tanlang'.tr} *'),
      SizedBox(height: AppDimensions.paddingSmall),
      Stack(
        children: [
          Container(
            height: Responsive.scaleHeight(300, context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              child: FormField<String>(
                key: _locationFieldKey,
                validator:
                    (value) =>
                        controller.latitudeController.text.isEmpty ||
                                controller.longitudeController.text.isEmpty
                            ? 'Joylashuv tanlanishi shart'.tr
                            : null,
                builder:
                    (formFieldState) => Column(
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
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: const ['a', 'b', 'c'],
                                userAgentPackageName: 'torex.top.ishtopchi',
                                tileProvider: CachedTileProvider(),
                              ),
                              Obx(
                                () => MarkerLayer(
                                  markers: [
                                    if (controller.currentLocation.value !=
                                        null)
                                      Marker(
                                        width: 40.0,
                                        height: 40.0,
                                        point:
                                            controller.currentLocation.value!,
                                        child: const AppMapPin(accent: false),
                                      ),
                                    Marker(
                                      width: 40.0,
                                      height: 40.0,
                                      point: controller.selectedLocation.value,
                                      child: const AppMapPin(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (formFieldState.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              formFieldState.errorText!,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
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
                _MapControl(
                  icon: LucideIcons.plus,
                  onPressed: () => controller.zoomIn(_moveMap),
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                _MapControl(
                  icon: LucideIcons.minus,
                  onPressed: () => controller.zoomOut(_moveMap),
                ),
              ],
            ),
          ),
          Positioned(
            right: AppDimensions.paddingSmall,
            bottom: AppDimensions.paddingSmall,
            child: _MapControl(
              icon: LucideIcons.locate,
              accent: true,
              tooltip: 'Joriy joylashuvni aniqlash'.tr,
              //onPressed: () => controller.getCurrentLocation(_moveMap)
              onPressed: () {
                controller.checkLocationPermission().then((value) async {
                  if (!value) {
                    await Permission.locationWhenInUse.request();
                  } else {
                    controller.getCurrentLocation(_moveMap);
                  }
                });
              },
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
    TextInputAction? textInputAction,
    // Bezak mavzudagi `inputDecorationTheme` dan keladi.
  }) => TextFormField(
    key: fieldKey,
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    style: Theme.of(context).textTheme.bodyMedium,
    validator: validator,
    textInputAction: textInputAction,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );

  Widget _buildDropdownField<T>(
    BuildContext context,
    String label,
    RxList<dynamic> items,
    Rx<T?> selectedValue,
    IconData icon,
    Function(T?) onChanged, {
    String? Function(T?)? validator,
    bool isInt = false,
    GlobalKey<FormFieldState>? fieldKey,
  }) => DropdownButtonFormField2<T>(
    key: fieldKey,
    value: selectedValue.value,
    isExpanded: true,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, size: 18),
      labelText: label,
    ),
    dropdownStyleData: DropdownStyleData(
      maxHeight: 240,
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      offset: const Offset(0, -6),
    ),
    iconStyleData: IconStyleData(
      icon: Icon(
        LucideIcons.chevronDown,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    ),
    style: Theme.of(context).textTheme.bodyMedium,
    items:
        items.map((item) {
          return DropdownMenuItem<T>(
            value:
                (item['id'] != null)
                    ? (isInt ? item['id'] as T : item['id'].toString() as T)
                    : item['value']
                        as T, // Bu qator o'zgardi: id mavjud bo'lsa, to'g'ri tipga o'tkazamiz
            child: Text(
              item['title'] ?? item['name'] ?? 'Noma’lum'.tr,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
    onChanged: onChanged,
    hint: Text(
      'Tanlang'.tr,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42),
      ),
    ),
  );

  /// Yuborish tugmasi.
  ///
  /// Ilgari qizil edi — qizil ilovada xato va oʻchirish uchun ishlatiladi.
  /// Asosiy harakat uchun brend rangi toʻgʻriroq.
  Widget _buildSubmitButton(BuildContext context) => Obx(
    () => AppButton(
      label: 'E’lonni yuborish'.tr,
      leading: const Icon(LucideIcons.send),
      filled: true,
      loading: controller.isSubmitting.value,
      onPressed:
          controller.isSubmitting.value
              ? null
              : () {
                if (_formKey.currentState!.validate()) {
                  controller.submitAd();
                } else {
                  _scrollToErrorField();
                }
              },
    ),
  );
}

/// Xarita ustidagi dumaloq boshqaruv tugmasi.
class _MapControl extends StatefulWidget {
  const _MapControl({
    required this.icon,
    required this.onPressed,
    this.accent = false,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool accent;
  final String? tooltip;

  @override
  State<_MapControl> createState() => _MapControlState();
}

class _MapControlState extends State<_MapControl> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = widget.accent ? colors.primary : colors.onSurface;

    Widget button = AnimatedScale(
      scale: _pressed ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Material(
        color: colors.surfaceContainer,
        shape: CircleBorder(
          side: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(widget.icon, size: 17, color: foreground),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}
