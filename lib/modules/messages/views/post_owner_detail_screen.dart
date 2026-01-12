import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../core/utils/responsive.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../controllers/messages_controller.dart';

class PostOwnerDetailScreen extends StatefulWidget {
  const PostOwnerDetailScreen({super.key});

  @override
  State<PostOwnerDetailScreen> createState() => _PostOwnerDetailScreenState();
}

class _PostOwnerDetailScreenState extends State<PostOwnerDetailScreen> {
  late final dynamic _room;
  late final User _otherUser;
  late final int? _currentUserId;
  late final MessagesController _messagesController;

  @override
  void initState() {
    super.initState();
    _room = Get.arguments;
    if (_room == null) {
      Get.snackbar('Error', 'Room not found');
      Get.back();
      return;
    }
    _currentUserId = Get.find<FuncController>().userMe.value.data!.id;
    _messagesController = Get.find<MessagesController>();
    _otherUser = _room.user1.id == _currentUserId ? _room.user2 : _room.user1;
  }

  @override
  Widget build(BuildContext context) {
    return _buildApplicationsScreen(context);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      title: Text(
        _room.application.post.title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: Responsive.scaleFont(18, context),
          color: AppColors.textColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textColor),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildApplicationsScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildApplicationsList(context),
    );
  }

  Widget _buildApplicationsList(BuildContext context) {
    return Obx(() {
      final applications =
          _messagesController.chatRoomsModel.value?.data.postOwnerRooms
              .where(
                (app) => app.application.post.id == _room.application.post.id,
              )
              .toList() ??
          [];
      if (applications.isEmpty) {
        return Center(
          child: Text(
            'No applications found',
            style: TextStyle(color: AppColors.textColor),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final room = applications[index];
          return _buildApplicationCard(context, room);
        },
      );
    });
  }

  Widget _buildApplicationCard(BuildContext context, PostOwnerRoom room) {
    final otherUser = room.user1.id == _currentUserId ? room.user2 : room.user1;
    final sender = '${otherUser.firstName} ${otherUser.lastName ?? ''}'.trim();
    final preview = room.application.message;
    final time = _formatTime(room.createdAt);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryColor,
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
    );
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.red),
              title: Text(
                'Xabarni o\'chirish',
                style: TextStyle(color: AppColors.textColor),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Xabar',
                  'Xabar o‘chirildi!',
                  backgroundColor: AppColors.primaryColor,
                  colorText: AppColors.textColor,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.red),
              title: Text(
                'Foydalanuvchini bloklash',
                style: TextStyle(color: AppColors.textColor),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Xabar',
                  'Foydalanuvchi bloklandi!',
                  backgroundColor: AppColors.primaryColor,
                  colorText: AppColors.textColor,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: AppColors.red),
              title: Text(
                'Shikoyat qilish',
                style: TextStyle(color: AppColors.textColor),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Xabar',
                  'Shikoyat yuborildi!',
                  backgroundColor: AppColors.primaryColor,
                  colorText: AppColors.textColor,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
