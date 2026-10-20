import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/devices_model.dart';

/// Hisobga kirgan qurilmalar.
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();

    // Qurilmalarni olish
    apiController.fetchDevices();

    return AppScreen(
      title: 'Mening qurilmalarim'.tr,
      child: Obx(() {
        if (funcController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (funcController.devicesModel.value.data == null ||
            funcController.devicesModel.value.data!.isEmpty) {
          return AppEmptyState(
            icon: LucideIcons.smartphone,
            title: 'Qurilmalar topilmadi'.tr,
          );
        }

        // Joriy qurilma va boshqa qurilmalarni ajratish
        final devices = funcController.devicesModel.value.data!;
        final currentDevice = devices.firstWhereOrNull(
          (device) => device.deviceId == funcController.deviceId.value,
        );
        final otherDevices =
            devices.where((device) => device != currentDevice).toList();

        var step = 0;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            // Joriy qurilma bo'limi
            if (currentDevice != null) ...[
              AppSectionLabel(text: 'Joriy qurilma'.tr),
              AppReveal(
                delay: AppReveal.step(step++),
                child: _DeviceCard(
                  device: currentDevice,
                  isCurrentDevice: true,
                  hasOtherDevices: otherDevices.isNotEmpty,
                  onOpen:
                      () => _showDeviceDialog(
                        context,
                        currentDevice,
                        apiController,
                      ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            // Boshqa qurilmalar bo'limi
            if (otherDevices.isNotEmpty) ...[
              AppSectionLabel(text: 'Boshqa qurilmalar'.tr),
              ...otherDevices.map(
                (device) => AppReveal(
                  delay: AppReveal.step(step++),
                  child: _DeviceCard(
                    device: device,
                    isCurrentDevice: false,
                    hasOtherDevices: false,
                    onOpen:
                        () => _showDeviceDialog(context, device, apiController),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  /// Qurilma tafsilotlari va oʻchirish oynasi.
  void _showDeviceDialog(
    BuildContext context,
    DevicesData device,
    ApiController apiController,
  ) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.deviceName ?? 'Noma’lum qurilma'.tr,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: LucideIcons.hash,
                label: 'ID',
                value: device.id?.toString() ?? 'Noma’lum'.tr,
              ),
              _InfoRow(
                icon: LucideIcons.smartphone,
                label: 'Model'.tr,
                value: device.deviceModel ?? 'Noma’lum'.tr,
              ),
              _InfoRow(
                icon:
                    device.platform == 'Android'
                        ? LucideIcons.tablet
                        : LucideIcons.apple,
                label: 'Platforma'.tr,
                value: device.platform ?? 'Noma’lum'.tr,
              ),
              _InfoRow(
                icon: LucideIcons.clock,
                label: 'Oxirgi kirish'.tr,
                value: device.lastLogin?.split('T')[0] ?? 'Noma’lum'.tr,
              ),
              _InfoRow(
                icon: LucideIcons.circleCheck,
                label: 'Faol'.tr,
                value: device.isActive == true ? 'Ha'.tr : 'Yo‘q'.tr,
                valueColor:
                    device.isActive == true ? AppColors.green : AppColors.red,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Yopish'.tr),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      apiController.deleteDevice(device.id!);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusControl,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: Text('Qurilmani o‘chirish'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bitta qurilma kartasi.
class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.isCurrentDevice,
    required this.hasOtherDevices,
    required this.onOpen,
  });

  final DevicesData device;
  final bool isCurrentDevice;

  /// Joriy qurilmada "boshqa seanslarni tugatish" tugmasi koʻrsatiladi.
  final bool hasOtherDevices;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);
    final radius = BorderRadius.circular(AppTheme.radiusCard);
    final active = device.isActive == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                // Joriy qurilma urgʻu konturi bilan ajralib turadi.
                color:
                    isCurrentDevice
                        ? colors.primary.withValues(alpha: 0.35)
                        : colors.onSurface.withValues(alpha: 0.08),
                width: isCurrentDevice ? 1.4 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        device.platform == 'Android'
                            ? LucideIcons.tablet
                            : LucideIcons.apple,
                        size: 19,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  device.deviceName ?? 'Noma’lum qurilma'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              if (isCurrentDevice) ...[
                                const SizedBox(width: 8),
                                _Badge(text: 'Joriy'.tr),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            device.deviceModel ?? 'Noma’lum model'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12.5,
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color:
                                      active ? AppColors.green : AppColors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${'Faol'.tr}: ${active ? 'Ha'.tr : 'Yo‘q'.tr}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11.5,
                                  color:
                                      active ? AppColors.green : AppColors.red,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                device.lastLogin?.split('T')[0] ??
                                    'Noma’lum'.tr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11.5,
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onOpen,
                      icon: Icon(
                        LucideIcons.trash2,
                        color: AppColors.red,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                if (isCurrentDevice && hasOtherDevices) ...[
                  Divider(
                    color: colors.onSurface.withValues(alpha: 0.10),
                    thickness: 1,
                    height: 20,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: Icon(
                        LucideIcons.hand,
                        color: AppColors.red,
                        size: 17,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.red,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      label: Text(
                        'Boshqa barcha seanslarni tugatish'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: onOpen,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kichik yorliq.
class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: colors.primary,
        ),
      ),
    );
  }
}

/// Oynadagi bitta maʼlumot qatori.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
