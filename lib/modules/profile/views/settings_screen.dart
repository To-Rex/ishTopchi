import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ishtopchi/modules/profile/controllers/profile_controller.dart';
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
            onPressed: () => Navigator.of(context).pop(),
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
                subtitle: 'Bildirishnomalarni yoqish-o‘chirish'.tr,
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
                    title: 'Qorong‘i rejim'.tr,
                    subtitle: 'Ilova dizaynini o‘zgartirish'.tr,
                    value: controller.isDarkMode.value,
                    onChanged: (value) {
                      controller.toggleTheme();
                    },
                  );
                },
              ),

              SizedBox(height: Responsive.scaleHeight(20, context)),
              _buildSectionHeader('Boshqa'.tr),
              _buildMenuTile(
                icon: LucideIcons.info,
                title: 'Versiya ma’lumotlari'.tr,
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

  void _showVersionInfo() {
    final themeController = Get.find<ThemeController>();
    final titleColor = AppColors.textColor;
    final labelColor = AppColors.textSecondaryColor;
    final valueColor = AppColors.textColor;
    final buttonColor = AppColors.primaryColor;
    final gradientColors =
        themeController.isDarkMode.value
            ? [AppColors.darkNavy, AppColors.darkBlue]
            : [AppColors.lightBackground, AppColors.lightSurface];

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Versiya ma’lumotlari'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),

                // Version Info Cards
                _buildVersionCard(
                  icon: LucideIcons.smartphone,
                  label: 'Ilova versiyasi'.tr,
                  value: ProfileController().appVersion,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                SizedBox(height: 12.h),
                _buildVersionCard(
                  icon: LucideIcons.monitor,
                  label: 'Qurilma'.tr,
                  value: 'Android / iOS',
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                SizedBox(height: 12.h),
                _buildVersionCard(
                  icon: LucideIcons.code,
                  label: 'Build'.tr,
                  value: '2025.01.10',
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
                SizedBox(height: 24.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Yopish'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard({
    required IconData icon,
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    final themeController = Get.find<ThemeController>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow:
            themeController.isDarkMode.value
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
