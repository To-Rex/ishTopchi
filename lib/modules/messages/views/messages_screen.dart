import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/common/widgets/text_small.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/not_logged.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/socket_service.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/messages_controller.dart';
import '../../../config/routes/app_routes.dart';

class MessagesScreen extends GetView<MessagesController> {
  MessagesScreen({super.key});
  final FuncController funcController = Get.find<FuncController>();

  final SocketService _socketService = SocketService();

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    // final socket = SocketService();
    // socket.onNewMessage((msg) => print('newMessage: $msg'));
    // socket.onMessageStatus((st) => print('messageStatus: $st'));
    // socket.onError((e) => print('SOCKET ERROR: $e'));
    // socket.connect(token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTEyLCJyb2xlIjoiVVNFUiIsImlhdCI6MTc1NDU2Nzg4NCwiZXhwIjoxNzg2MTAzODg0fQ.oRzyoRtRkuls_4ObF4XrDlMmOCQ6YE9r_3u065bKtMY');
    // socket.joinChat(64);
    // socket.sendMessage(chatRoomId: 64, content: 'Salom!');
    // socket.sendMessage(chatRoomId: 64, content: 'Salom!');
    // socket.updatePresence(true);

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (funcController.getToken() == null || funcController.getToken() == '') {
      return NotLogged();
    }
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.iconColor),
        );
      }
      if (controller.chatRoomsModel.value == null) {
        return _buildEmptyState(context);
      }
      final currentUserId = funcController.userMe.value.data?.id ?? 0;
      final postOwnerRooms =
          controller.chatRoomsModel.value!.data.postOwnerRooms;
      final applicationRooms =
          controller.chatRoomsModel.value!.data.applicationRooms;

      // Check if both lists are empty
      if (postOwnerRooms.isEmpty && applicationRooms.isEmpty) {
        return _buildEmptyState(context);
      }

      return ListView(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          if (postOwnerRooms.isNotEmpty) ...[
            TextSmall(
              text: 'Post Owner Rooms'.tr,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            ...postOwnerRooms.map(
              (room) => _buildRoomCard(context, room, currentUserId, true),
            ),
          ],
          if (applicationRooms.isNotEmpty) ...[
            if (postOwnerRooms.isNotEmpty)
              SizedBox(height: AppDimensions.paddingMedium),
            TextSmall(
              text: 'Application Rooms'.tr,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            ...applicationRooms.map(
              (room) => _buildRoomCard(context, room, currentUserId, false),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 54.sp,
              color: AppColors.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Hozircha xabarlar yo\'q'.tr,
              style: AppTheme.theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.textColor,
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Xabarlar bo‘lishi uchun e’lonlarga ariza yuboring'.tr,
              style: AppTheme.theme.textTheme.bodyMedium!.copyWith(
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                backgroundColor: AppColors.cardColor,
              ),
              onPressed: () => Get.toNamed(AppRoutes.main),
              child: Text(
                'Asosiy sahifaga o‘tish'.tr,
                style: TextStyle(color: AppColors.textColor, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    dynamic room,
    int currentUserId,
    bool isPostOwner,
  ) {
    final otherUser = room.user1.id == currentUserId ? room.user2 : room.user1;
    final sender = '${otherUser.firstName} ${otherUser.lastName ?? ''}'.trim();
    final preview =
        isPostOwner ? room.application.post.title : room.application.message;
    final time = _formatTime(room.createdAt);

    return Card(
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child:
          isPostOwner
              ? InkWell(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                onTap: () {
                  Get.toNamed(AppRoutes.postOwnerDetail, arguments: room);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: AppDimensions.paddingSmall,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        child: Container(
                          width: Responsive.scaleWidth(80, context),
                          height: Responsive.scaleWidth(80, context),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondaryColor.withAlpha(50),
                          ),
                          child:
                              room.application.post?.pictureUrl != null &&
                                      room
                                          .application
                                          .post
                                          .pictureUrl!
                                          .isNotEmpty
                                  ? Image.network(
                                    'https://ishtopchi.uz${room.application.post.pictureUrl}',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Center(
                                          child: Icon(
                                            LucideIcons.imageOff,
                                            color: AppColors.textSecondaryColor,
                                            size: 40,
                                          ),
                                        ),
                                  )
                                  : Center(
                                    child: Icon(
                                      LucideIcons.imageOff,
                                      color: AppColors.textSecondaryColor,
                                      size: 40,
                                    ),
                                  ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.paddingMedium),
                      // Post details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post title
                            Text(
                              room.application.post?.title ?? 'Noma’lum',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(16, context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            SizedBox(height: AppDimensions.paddingSmall),
                            // Salary
                            if (room.application.post?.salaryFrom != null ||
                                room.application.post?.salaryTo != null)
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.wallet,
                                    size: Responsive.scaleFont(14, context),
                                    color: AppColors.iconColor,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${room.application.post?.salaryFrom ?? 'Noma’lum'} - ${room.application.post?.salaryTo ?? 'Noma’lum'} UZS',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: Responsive.scaleFont(
                                          12,
                                          context,
                                        ),
                                        color: AppColors.iconColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: AppDimensions.paddingSmall),
                            // Time
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(12, context),
                                color: AppColors.iconColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage:
                      isPostOwner && room.application.post.pictureUrl != null
                          ? NetworkImage(room.application.post.pictureUrl!)
                          : null,
                  child: Text(
                    sender[0].toUpperCase(),
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
                title: Text(
                  sender,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: Responsive.scaleFont(16, context),
                  ),
                ),
                subtitle: Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: Responsive.scaleFont(14, context),
                    color: AppColors.iconColor.withOpacity(0.8),
                  ),
                ),
                trailing: Text(
                  time,
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(12, context),
                    color: AppColors.iconColor,
                  ),
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.messagesDetail, arguments: room);
                },
              ),
    );
  }

  String _formatTime(String createdAt) {
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
}
