import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:get/get.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../core/utils/responsive.dart';

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
      Get.back();
      Get.snackbar(
        'Xatolik'.tr,
        'Xarita ilovalari topilmadi'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.cardColor,
        colorText: AppColors.textColor,
      );
      return;
    }

    if (availableMaps.isEmpty) {
      Get.back();
      Get.snackbar(
        'Xatolik'.tr,
        'Xarita ilovalari topilmadi'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.cardColor,
        colorText: AppColors.textColor,
      );
      return;
    }

    if (!context.mounted) return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8, width: double.infinity),
            Container(
              alignment: Alignment.center,
              height: 180,
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.iconColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    child: Text(
                      'Quyidagilar orqali ochish:'.tr,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(16, context),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingSmall,
                      ),
                      child: Row(
                        children:
                            availableMaps.map((map) {
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () async {
                                    Get.back();
                                    HapticFeedback.lightImpact();
                                    await map.showMarker(
                                      coords: Coords(
                                        coordinates.latitude,
                                        coordinates.longitude,
                                      ),
                                      title: title ?? 'Joylashuv',
                                    );
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: SvgPicture.asset(
                                            map.icon,
                                            height: 50.0,
                                            width: 50.0,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          map.mapName,
                                          style: TextStyle(
                                            fontSize: Responsive.scaleFont(
                                              15,
                                              context,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textColor,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingMedium),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              margin: EdgeInsets.only(
                top: AppDimensions.paddingMedium,
                bottom: AppDimensions.paddingLarge,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.iconColor.withAlpha(50),
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  HapticFeedback.lightImpact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Bekor qilish'.tr,
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(16, context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
