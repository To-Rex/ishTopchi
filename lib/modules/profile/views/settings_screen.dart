import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../controllers/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();
  late ThemeController themeController;
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = false;
  String _selectedLanguage = 'uz';

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    _loadSettings();
  }

  void _loadSettings() {
    final language = storage.read('language') ?? 'uz';
    setState(() {
      _notificationsEnabled = storage.read('notifications_enabled') ?? true;
      _autoPlayEnabled = storage.read('auto_play_enabled') ?? false;
      _selectedLanguage = language;
    });

    // Update locale after build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(language));
    });
  }

  void _saveSetting(String key, bool value) {
    storage.write(key, value);
  }

  void _saveLanguage(String language) {
    storage.write('language', language);
    setState(() {
      _selectedLanguage = language;
    });
    // Update locale after build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(language));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      final backgroundColor = AppColors.backgroundColor;
      final gradientColors =
          themeController.isDarkMode.value
              ? [AppColors.darkNavy, AppColors.darkBlue]
              : [AppColors.lightBackground, AppColors.lightSurface];
      final textColor = AppColors.textColor;
      final subtitleColor = AppColors.textSecondaryColor;
      final cardColor = AppColors.cardColor;

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: textColor,
              size: Responsive.scaleFont(25, context),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Sozlamalar'.tr,
            style: TextStyle(
              color: textColor,
              fontSize: Responsive.scaleFont(20, context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scaleWidth(16, context),
              vertical: Responsive.scaleHeight(16, context),
            ),
            children: [
              _buildSectionHeader('Umumiy'.tr),
              _buildLanguageTile(
                icon: LucideIcons.globe,
                title: 'Tillar'.tr,
                subtitle: 'Ilova tilini tanlang'.tr,
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: (language) => _saveLanguage(language),
              ),
              _buildSwitchTile(
                icon: LucideIcons.bell,
                title: 'Bildirishnomalar'.tr,
                subtitle: 'Bildirishnomalarni yoqish-o\'chirish'.tr,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSetting('notifications_enabled', value);
                },
              ),
              GetX<ThemeController>(
                builder: (controller) {
                  return _buildSwitchTile(
                    icon: LucideIcons.moon,
                    title: 'Qorong\'u rejim'.tr,
                    subtitle: 'Ilova dizaynini o\'zgartirish'.tr,
                    value: controller.isDarkMode.value,
                    onChanged: (value) {
                      controller.toggleTheme();
                    },
                  );
                },
              ),
              SizedBox(height: Responsive.scaleHeight(20, context)),
              _buildSectionHeader('Kontent'.tr),
              _buildSwitchTile(
                icon: LucideIcons.play,
                title: 'Avtomatik ijro'.tr,
                subtitle: 'Videolarni avtomatik ijro etish'.tr,
                value: _autoPlayEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoPlayEnabled = value;
                  });
                  _saveSetting('auto_play_enabled', value);
                },
              ),
              SizedBox(height: Responsive.scaleHeight(20, context)),
              _buildSectionHeader('Ma\'lumot'.tr),
              _buildMenuTile(
                icon: LucideIcons.shield,
                title: 'Xavfsizlik'.tr,
                subtitle: 'Xavfsizlik sozlamalari'.tr,
                onTap: () {
                  Get.snackbar(
                    'Xavfsizlik'.tr,
                    'Xavfsizlik sozlamalari tez orada qo\'shiladi'.tr,
                    backgroundColor: AppColors.darkBlue,
                    colorText: Colors.white,
                  );
                },
              ),
              _buildMenuTile(
                icon: LucideIcons.database,
                title: 'Keshni tozalash'.tr,
                subtitle: 'Ilova keshini tozalash'.tr,
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              SizedBox(height: Responsive.scaleHeight(20, context)),
              _buildSectionHeader('Boshqa'.tr),
              _buildMenuTile(
                icon: LucideIcons.fileText,
                title: 'Foydalanish shartlari'.tr,
                subtitle: 'Foydalanish shartlarini ko\'rish'.tr,
                onTap: () {
                  Get.snackbar(
                    'Foydalanish shartlari'.tr,
                    'Foydalanish shartlari tez orada qo\'shiladi'.tr,
                    backgroundColor: AppColors.darkBlue,
                    colorText: Colors.white,
                  );
                },
              ),
              _buildMenuTile(
                icon: LucideIcons.info,
                title: 'Versiya ma\'lumotlari'.tr,
                subtitle: 'Ilova versiyasi va yangilanishlar'.tr,
                onTap: () {
                  _showVersionInfo();
                },
              ),
              SizedBox(height: Responsive.scaleHeight(30, context)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Responsive.scaleHeight(12, context),
        left: Responsive.scaleWidth(4, context),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textSecondaryColor,
          fontSize: Responsive.scaleFont(14, context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final themeController = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.scaleHeight(8, context)),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            themeController.isDarkMode.value
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.iconColor,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade700,
        secondary: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(22, context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: Responsive.scaleFont(13, context),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String selectedLanguage,
    required ValueChanged<String> onLanguageChanged,
  }) {
    final themeController = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.scaleHeight(8, context)),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            themeController.isDarkMode.value
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(22, context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: Responsive.scaleFont(13, context),
          ),
        ),
        trailing: DropdownButton<String>(
          value: selectedLanguage,
          dropdownColor: AppColors.surfaceColor,
          icon: Icon(Icons.arrow_drop_down, color: AppColors.iconColor),
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(14, context),
            fontWeight: FontWeight.w600,
          ),
          underline: const SizedBox.shrink(),
          items:
              const {
                'uz': 'O‘zbek',
                'ru': 'Русский',
                'en': 'English',
              }.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
          onChanged: (value) {
            if (value != null) {
              onLanguageChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeController = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.scaleHeight(8, context)),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            themeController.isDarkMode.value
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: AppColors.iconColor,
          size: Responsive.scaleFont(22, context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondaryColor,
            fontSize: Responsive.scaleFont(13, context),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondaryColor,
          size: Responsive.scaleFont(16, context),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final dialogColor = AppColors.cardColor;
    final titleColor = AppColors.textColor;
    final contentColor = AppColors.textSecondaryColor;
    final buttonColor = AppColors.primaryColor;
    final overlayColor = AppColors.backgroundColor;
    final textColor = AppColors.textColor;

    Get.dialog(
      AlertDialog(
        backgroundColor: dialogColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Keshni tozalash'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Keshni tozalashdan so\'ng ba\'zi ma\'lumotlar qayta yuklanishi kerak bo\'ladi. Davom etasizmi?'
              .tr,
          style: TextStyle(
            fontSize: 14.sp,
            color: contentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              overlayColor: overlayColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Bekor qilish'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Muvaffaqiyatli'.tr,
                'Kesh tozalandi'.tr,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Tozalash'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    final dialogColor = AppColors.cardColor;
    final titleColor = AppColors.textColor;
    final labelColor = AppColors.textSecondaryColor;
    final valueColor = AppColors.textColor;
    final buttonColor = AppColors.primaryColor;
    final overlayColor = AppColors.backgroundColor;

    Get.dialog(
      AlertDialog(
        backgroundColor: dialogColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Versiya ma\'lumotlari'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            color: titleColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionRow(
              'Ilova versiyasi'.tr,
              '1.1.0',
              labelColor,
              valueColor,
            ),
            SizedBox(height: 8.h),
            _buildVersionRow(
              'Qurilma'.tr,
              'Android / iOS',
              labelColor,
              valueColor,
            ),
            SizedBox(height: 8.h),
            _buildVersionRow('Build'.tr, '2024.01.10', labelColor, valueColor),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                overlayColor: overlayColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              child: Text(
                'Yopish'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
