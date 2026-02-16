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
import '../../../core/models/chat_rooms.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/messages_controller.dart';
import '../../../config/routes/app_routes.dart';

class MessagesScreen extends GetView<MessagesController> {
  MessagesScreen({super.key});
  final FuncController funcController = Get.find<FuncController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
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
              (room) => _buildPostOwnerRoomCard(context, room, currentUserId),
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
              (room) => _buildRoomCard(context, room, currentUserId),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleWidth(32, context),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with gradient background
              Container(
                width: Responsive.scaleWidth(120, context),
                height: Responsive.scaleWidth(120, context),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.1),
                      AppColors.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.messageSquare,
                  size: Responsive.scaleWidth(56, context),
                  color: AppColors.iconColor.withOpacity(0.6),
                ),
              ),
              SizedBox(height: Responsive.scaleHeight(24, context)),
              // Title
              Text(
                "Hozircha xabarlar yo'q".tr,
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: Responsive.scaleFont(20, context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              // Subtitle
              Text(
                "Xabarlar bo'lishi uchun e'lonlarga ariza yuboring".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontSize: Responsive.scaleFont(14, context),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: Responsive.scaleHeight(32, context)),
              // Button
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.main),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleWidth(24, context),
                    vertical: Responsive.scaleHeight(14, context),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.house,
                        size: Responsive.scaleWidth(18, context),
                        color: AppColors.white,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Text(
                        "Asosiy sahifaga o'tish".tr,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: Responsive.scaleFont(14, context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostOwnerRoomCard(
    BuildContext context,
    PostOwnerRoom room,
    int currentUserId,
  ) {
    final post = room.post;
    final chatCount = room.chatRooms.length;
    final latestChat = room.chatRooms.isNotEmpty ? room.chatRooms.first : null;
    final time = latestChat != null ? _formatTime(latestChat.createdAt) : '';

    return Card(
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        onTap: () {
          Get.toNamed(AppRoutes.postOwnerDetail, arguments: room);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: Container(
                  width: Responsive.scaleWidth(80, context),
                  height: Responsive.scaleWidth(80, context),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryColor.withAlpha(50),
                  ),
                  child:
                      post.pictureUrl != null && post.pictureUrl!.isNotEmpty
                          ? Image.network(
                            'https://ishtopchi.uz${post.pictureUrl}',
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
                      post.title ?? 'Noma’lum'.tr,
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
                    if (post.salaryFrom != null || post.salaryTo != null)
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
                              '${post.salaryFrom ?? 'Noma\'lum'} - ${post.salaryTo ?? 'Noma\'lum'} UZS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Responsive.scaleFont(12, context),
                                color: AppColors.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: AppDimensions.paddingSmall),
                    // Chat count and time
                    Row(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: Responsive.scaleFont(14, context),
                          color: AppColors.iconColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$chatCount ${chatCount == 1 ? 'chat' : 'chats'}',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(12, context),
                            color: AppColors.iconColor,
                          ),
                        ),
                        if (time.isNotEmpty) ...[
                          SizedBox(width: AppDimensions.paddingMedium),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(12, context),
                              color: AppColors.iconColor,
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
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    ApplicationRoom room,
    int currentUserId,
  ) {
    final otherUser = room.user1.id == currentUserId ? room.user2 : room.user1;
    final sender =
        '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim();
    final senderInitial = sender.isNotEmpty ? sender[0].toUpperCase() : '?';
    final preview = room.application.message ?? '';
    final time = _formatTime(room.createdAt);

    return Card(
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        onTap: () {
          Get.toNamed(AppRoutes.messagesDetail, arguments: room);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                backgroundImage:
                    otherUser.profilePicture != null
                        ? NetworkImage(otherUser.profilePicture!)
                        : null,
                child:
                    otherUser.profilePicture == null
                        ? Text(
                          senderInitial,
                          style: TextStyle(color: AppColors.white),
                        )
                        : null,
              ),
              SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sender,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(16, context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(14, context),
                        color: AppColors.iconColor.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 4),
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
