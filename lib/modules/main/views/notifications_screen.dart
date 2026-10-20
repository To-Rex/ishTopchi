import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_theme.dart';
import '../controllers/notification_controller.dart';

/// Bildirishnomalar roʻyxati.
class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Bildirishnomalar'.tr,
      actions: [
        // Faqat oʻqilmagan bildirishnoma boʻlsa koʻrinadi — avvalgidek.
        Obx(
          () =>
              controller.notifications.any((n) => !n.isRead)
                  ? IconButton(
                    icon: const Icon(LucideIcons.checkCheck),
                    onPressed: () async {
                      await controller.markAllAsRead();
                    },
                    tooltip: 'Barchasini o\'qilgan deb belgilash'.tr,
                  )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(width: 4),
      ],
      child: Obx(() {
        if (controller.notifications.isEmpty) {
          return AppEmptyState(
            icon: LucideIcons.bell,
            title: 'Hech qanday bildirishnoma yo‘q'.tr,
            message: 'Bildirishnomalar topilmadi tavsifi'.tr,
            actionLabel: 'Qayta yuklash'.tr,
            actionIcon: const Icon(LucideIcons.refreshCw),
            onAction: () => controller.refreshNotifications(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshNotifications(),
          color: Theme.of(context).colorScheme.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return AppReveal(
                delay: AppReveal.step(index),
                child: _NotificationTile(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      await controller.markAsRead(index);
                    }
                    // `await` dan keyin ekran yopilgan boʻlishi mumkin.
                    if (!context.mounted) return;
                    _showNotificationBottomSheet(notification, context);
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showNotificationBottomSheet(
    Notification notification,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Get.bottomSheet(
      SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusSheet),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusPill(isRead: notification.isRead),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(notification.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                notification.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 15,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    notification.time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black54,
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 250),
    );
  }
}

/// Oʻqilgan / oʻqilmagan holati.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color =
        isRead ? colors.onSurface.withValues(alpha: 0.5) : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isRead ? 'O‘qilgan'.tr : 'O‘qilmagan'.tr,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Roʻyxatdagi bitta bildirishnoma.
///
/// Oʻqilmaganlik ramka bilan emas, chapdagi kichik nuqta va qalinroq
/// sarlavha bilan koʻrsatiladi — bu tinchroq va aniqroq.
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final unread = !notification.isRead;
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        unread
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.onSurface.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.bell,
                    size: 17,
                    color:
                        unread
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    unread ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colors.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
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

class Notification {
  final int id;
  final String title;
  final String description;
  final String time;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}
