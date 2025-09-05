import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/models/devices_model.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});


  showDeleteDialog(context, DevicesData device, ApiController apiController, int id) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3))]
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.deviceName ?? 'Noma’lum qurilma'.tr, style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(18, context), fontWeight: FontWeight.w800)),
                SizedBox(height: Responsive.scaleHeight(12, context)),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.hash,
                  label: 'ID',
                  value: device.id?.toString() ?? 'Noma’lum'.tr,
                ),
                SizedBox(height: Responsive.scaleHeight(8, context)),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.smartphone,
                  label: 'Model'.tr,
                  value: device.deviceModel ?? 'Noma’lum'.tr,
                ),
                SizedBox(height: Responsive.scaleHeight(8, context)),
                _buildInfoRow(
                  context,
                  icon: device.platform == 'Android' ? LucideIcons.tablet : LucideIcons.apple,
                  label: 'Platforma'.tr,
                  value: device.platform ?? 'Noma’lum'.tr,
                ),
                SizedBox(height: Responsive.scaleHeight(8, context)),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.clock,
                  label: 'Oxirgi kirish'.tr,
                  value: device.lastLogin?.split('T')[0] ?? 'Noma’lum'.tr,
                ),
                SizedBox(height: Responsive.scaleHeight(8, context)),
                _buildInfoRow(
                  context,
                  icon: LucideIcons.circleCheck,
                  label: 'Faol'.tr,
                  value: device.isActive == true ? 'Ha'.tr : 'Yo‘q'.tr,
                  valueColor: device.isActive == true ? Colors.green : Colors.redAccent,
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Yopish'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(16, context)),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.red],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            apiController.deleteDevice(device.id!);
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.scaleHeight(10, context),
                              horizontal: Responsive.scaleWidth(16, context),
                            ),
                            child: Text(
                              'Qurilmani o‘chirish'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.scaleFont(14, context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(8, context)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();

    // Qurilmalarni olish
    apiController.fetchDevices();

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(25, context)), onPressed: () => Get.back(),),
        title: Text('Mening qurilmalarim'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(20, context), fontWeight: FontWeight.bold))
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkNavy, AppColors.darkBlue], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Obx(() {
          if (funcController.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2));
          }
          if (funcController.devicesModel.value.data == null || funcController.devicesModel.value.data!.isEmpty) {
            return Center(child: Text('Qurilmalar topilmadi'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500)));
          }

          // Joriy qurilma va boshqa qurilmalarni ajratish
          final devices = funcController.devicesModel.value.data!;
          final currentDevice = devices.firstWhereOrNull((device) => device.deviceId == funcController.deviceId.value);
          final otherDevices = devices.where((device) => device != currentDevice).toList();

          return AnimationLimiter(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(16, context)),
              children: [
                // Joriy qurilma bo‘limi
                if (currentDevice != null) ...[
                  Text('Joriy qurilma'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context), fontWeight: FontWeight.bold)),
                  SizedBox(height: Responsive.scaleHeight(8, context)),
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 600),
                    child: SlideAnimation(verticalOffset: 20.0, curve: Curves.easeOutBack, child: FadeInAnimation(child: _buildDeviceCard(context, currentDevice, apiController, true, otherDevices)))
                  ),
                  SizedBox(height: Responsive.scaleHeight(24, context))
                ],
                // Boshqa qurilmalar bo‘limi
                if (otherDevices.isNotEmpty) ...[
                  Text('Boshqa qurilmalar'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context), fontWeight: FontWeight.bold)),
                  SizedBox(height: Responsive.scaleHeight(8, context)),
                  ...otherDevices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final device = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index + (currentDevice != null ? 1 : 0),
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(verticalOffset: 20.0, curve: Curves.easeOutBack, child: FadeInAnimation(child: _buildDeviceCard(context, device, apiController, false, otherDevices)))
                    );
                  })
                ]
              ]
            )
          );
        })
      )
    );
  }

  Widget _buildDeviceCard(BuildContext context, DevicesData device, ApiController apiController, bool isCurrentDevice, otherDevices) {
    return GestureDetector(
      onTap: () => showDeleteDialog(context, device, apiController, device.id!),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(8, context)),
        padding: EdgeInsets.all(Responsive.scaleWidth(14, context)),
        decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(device.platform == 'Android' ? LucideIcons.tablet : LucideIcons.apple, color: isCurrentDevice ? Colors.white : AppColors.lightBlue, size: Responsive.scaleFont(25, context))
                ),
                SizedBox(width: Responsive.scaleWidth(15, context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentDevice ? '${device.deviceName ?? {'Noma’lum qurilma'.tr}} ${'Joriy'.tr}' : device.deviceName ?? 'Noma’lum qurilma'.tr,
                        style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                      ),
                      SizedBox(height: Responsive.scaleHeight(4, context)),
                      Text(
                        device.deviceModel ?? 'Noma’lum model'.tr,
                        style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.scaleHeight(4, context)),
                      Row(
                        children: [
                          Text(
                            '${'Faol'.tr}: ${device.isActive == true ? 'Ha'.tr : 'Yo‘q'.tr}',
                            style: TextStyle(
                              color: device.isActive == true ? Colors.green : Colors.redAccent,
                              fontSize: Responsive.scaleFont(13, context),
                              fontStyle: FontStyle.italic
                            )
                          ),
                          SizedBox(width: Responsive.scaleWidth(8, context)),
                          Text(
                            device.lastLogin?.split('T')[0] ?? 'Noma’lum'.tr,
                            style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(13, context), fontStyle: FontStyle.italic)
                          )
                        ]
                      )
                    ]
                  )
                ),
                IconButton(
                  onPressed: () {
                    showDeleteDialog(context, device, apiController, device.id!);
                  },
                  icon: Icon(
                    LucideIcons.trash2,
                    color: AppColors.red,
                    size: Responsive.scaleFont(22, context),
                  ),
                ),
              ],
            ),
            if (isCurrentDevice && otherDevices.isNotEmpty) ...[
              Divider(color: AppColors.lightGray, thickness: 0.7),
              TextButton.icon(
                icon: Icon(LucideIcons.hand, color: AppColors.red, size: Responsive.scaleFont(18, context)),
                style: TextButton.styleFrom(shadowColor: AppColors.red, overlayColor: AppColors.red, minimumSize: Size.square(Responsive.scaleHeight(40, context)), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                label: Text('Boshqa barcha seanslarni tugatish'.tr, style: TextStyle(color: AppColors.red, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w600)),
                onPressed: () => showDeleteDialog(context, device, apiController, device.id!)
              )
            ]
          ]
        )
      )
    );
  }


  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.lightBlue, size: Responsive.scaleFont(18, context)),
        SizedBox(width: Responsive.scaleWidth(8, context)),
        Text('$label: ', style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))
      ]
    );
  }
}