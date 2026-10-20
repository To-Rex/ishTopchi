import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';

/// Joylashuvni tashqi xarita ilovasida ochish uchun varaq.
class MapLauncherBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required LatLng coordinates,
    String? title,
  }) async {
    HapticFeedback.lightImpact();

    List<AvailableMap> availableMaps;

    try {
      availableMaps = await MapLauncher.installedMaps;
    } catch (e) {
      //Get.back();
      // `await` dan keyin ekran yopilgan boʻlishi mumkin.
      if (context.mounted) Navigator.of(context).pop();
      _showError();
      return;
    }

    if (availableMaps.isEmpty) {
      if (context.mounted) Navigator.of(context).pop();
      //Get.back();
      _showError();
      return;
    }

    if (!context.mounted) return;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSheet),
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Quyidagilar orqali ochish:'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        itemCount: availableMaps.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final map = availableMaps[index];
                          return _MapTile(
                            map: map,
                            onTap: () async {
                              Navigator.of(context).pop();
                              HapticFeedback.lightImpact();
                              await map.showMarker(
                                coords: Coords(
                                  coordinates.latitude,
                                  coordinates.longitude,
                                ),
                                title: title ?? 'Joylashuv',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: TextButton(
                  onPressed: () {
                    // Get.back();
                    Navigator.of(context).pop();
                    HapticFeedback.lightImpact();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        theme.cardTheme.color ?? colors.surfaceContainer,
                    foregroundColor: colors.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusControl,
                      ),
                      side: BorderSide(
                        color: colors.onSurface.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Bekor qilish'.tr,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  static void _showError() {
    Get.snackbar(
      'Xatolik'.tr,
      'Xarita ilovalari topilmadi'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardColor,
      colorText: AppColors.textColor,
    );
  }
}

/// Bitta xarita ilovasi.
class _MapTile extends StatelessWidget {
  const _MapTile({required this.map, required this.onTap});

  final AvailableMap map;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(14);

    return SizedBox(
      width: 92,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(map.icon, height: 46, width: 46),
                ),
                const SizedBox(height: 8),
                Text(
                  map.mapName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
