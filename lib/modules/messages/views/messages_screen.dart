import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/chat_rooms.dart';
import '../controllers/messages_controller.dart';

/// Suhbatlar roʻyxati.
class MessagesScreen extends GetView<MessagesController> {
  MessagesScreen({super.key});

  final FuncController funcController = Get.find<FuncController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AppContentWidth(child: _buildBody(context)));
  }

  Widget _buildBody(BuildContext context) {
    if (funcController.getToken() == null || funcController.getToken() == '') {
      return NotLogged();
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.chatRoomsModel.value == null) {
        return _buildEmptyState();
      }

      final currentUserId = funcController.userMe.value.data?.id ?? 0;
      final postOwnerRooms =
          controller.chatRoomsModel.value!.data.postOwnerRooms;
      final applicationRooms =
          controller.chatRoomsModel.value!.data.applicationRooms;

      // Check if both lists are empty
      if (postOwnerRooms.isEmpty && applicationRooms.isEmpty) {
        return _buildEmptyState();
      }

      // Kirish animatsiyasi uchun umumiy hisoblagich: ikkala roʻyxat
      // bir butun ketma-ketlik boʻlib chiqadi.
      var index = 0;

      return ListView(
        // Oxirgi suhbat pastki suzuvchi panel ostida qolmasin.
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (postOwnerRooms.isNotEmpty) ...[
            _SectionLabel(text: 'Post Owner Rooms'.tr),
            const SizedBox(height: 10),
            ...postOwnerRooms.map(
              (room) => AppReveal(
                delay: AppReveal.step(index++),
                child: _PostOwnerRoomCard(room: room),
              ),
            ),
          ],
          if (applicationRooms.isNotEmpty) ...[
            if (postOwnerRooms.isNotEmpty) const SizedBox(height: 22),
            _SectionLabel(text: 'Application Rooms'.tr),
            const SizedBox(height: 10),
            ...applicationRooms.map(
              (room) => AppReveal(
                delay: AppReveal.step(index++),
                child: _ApplicationRoomCard(
                  room: room,
                  currentUserId: currentUserId,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: LucideIcons.messageSquare,
      title: "Hozircha xabarlar yo'q".tr,
      message: "Xabarlar bo'lishi uchun e'lonlarga ariza yuboring".tr,
      actionLabel: "Asosiy sahifaga o'tish".tr,
      actionIcon: const Icon(LucideIcons.house),
      //onTap: () => Get.toNamed(AppRoutes.main),
      onAction: () => funcController.setBarIndex(0),
    );
  }
}

/// Roʻyxat boʻlimining sarlavhasi.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        fontSize: 11.5,
        letterSpacing: 1.2,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Kartaning umumiy qobigʻi.
class _RoomShell extends StatelessWidget {
  const _RoomShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Eʼlon egasining suhbatlari.
class _PostOwnerRoomCard extends StatelessWidget {
  const _PostOwnerRoomCard({required this.room});

  final PostOwnerRoom room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);

    final post = room.post;
    final chatCount = room.chatRooms.length;
    final latestChat = room.chatRooms.isNotEmpty ? room.chatRooms.first : null;
    final time = latestChat != null ? formatChatTime(latestChat.createdAt) : '';

    return _RoomShell(
      onTap: () => Get.toNamed(AppRoutes.postOwnerDetail, arguments: room),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: _PostImage(url: post.pictureUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title ?? 'Noma’lum'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                if (post.salaryFrom != null || post.salaryTo != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${post.salaryFrom ?? 'Noma\'lum'} - ${post.salaryTo ?? 'Noma\'lum'} UZS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: 13, color: muted),
                    const SizedBox(width: 5),
                    Text(
                      '$chatCount ${chatCount == 1 ? 'chat' : 'chats'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                    if (time.isNotEmpty) ...[
                      const Spacer(),
                      Text(
                        time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Arizaga tegishli suhbat.
class _ApplicationRoomCard extends StatelessWidget {
  const _ApplicationRoomCard({required this.room, required this.currentUserId});

  final ApplicationRoom room;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);

    final otherUser = room.user1.id == currentUserId ? room.user2 : room.user1;
    final sender =
        '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim();
    final senderInitial = sender.isNotEmpty ? sender[0].toUpperCase() : '?';
    final preview = room.application.message ?? '';
    final time = formatChatTime(room.createdAt);

    return _RoomShell(
      onTap: () => Get.toNamed(AppRoutes.messagesDetail, arguments: room),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            backgroundImage:
                otherUser.profilePicture != null
                    ? NetworkImage(otherUser.profilePicture!)
                    : null,
            child:
                otherUser.profilePicture == null
                    ? Text(
                      senderInitial,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    )
                    : null,
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
                        sender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: muted,
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

/// Eʼlon surati yoki uning oʻrnidagi belgi.
class _PostImage extends StatelessWidget {
  const _PostImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = colors.onSurface.withValues(alpha: 0.06);

    Widget fallback() => Container(
      color: placeholder,
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.imageOff,
        size: 22,
        color: colors.onSurface.withValues(alpha: 0.3),
      ),
    );

    if (url == null || url!.isEmpty) return fallback();

    return CachedNetworkImage(
      imageUrl: 'https://ishtopchi.uz$url',
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (context, _) => Container(color: placeholder),
      errorWidget: (context, _, _) => fallback(),
    );
  }
}

/// Suhbat vaqtini qisqa koʻrinishda beradi.
String formatChatTime(String createdAt) {
  try {
    final dateTime = DateTime.parse(createdAt).toLocal();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today, show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      // For older dates, show date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  } catch (e) {
    return createdAt; // Fallback to original string
  }
}
