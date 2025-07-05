import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/models/message_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/messages_controller.dart';

class MessageDetailScreen extends GetView<MessagesController> {
  MessageDetailScreen({super.key});

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Message message = Get.arguments as Message;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: _buildAppBar(context, message),
      body: _buildBody(context, message),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Message message) {
    return AppBar(
      backgroundColor: AppColors.darkNavy,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.midBlue,
            radius: Responsive.scaleWidth(20, context),
            child: Text(
              message.sender[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: Responsive.scaleFont(16, context),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              message.sender,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: Responsive.scaleFont(18, context),
                color: AppColors.lightGray,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.lightGray),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call, color: AppColors.lightGray),
          onPressed: () {
            Get.snackbar('Xabar', 'Qo‘ng‘iroq funksiyasi tez kunda qo‘shiladi!',
                backgroundColor: AppColors.midBlue, colorText: AppColors.lightGray);
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.lightGray),
          onPressed: () {
            _showMoreOptions(context);
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Message message) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final chatMessages = controller.chatMessages[message.sender] ?? <ChatMessage>[].obs;
            return ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final chatMessage = chatMessages[chatMessages.length - 1 - index];
                return _buildMessageBubble(context, chatMessage);
              },
            );
          }),
        ),
        _buildMessageInput(context, message.sender),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage chatMessage) {
    return Align(
      alignment: chatMessage.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
          horizontal: AppDimensions.paddingMedium,
        ),
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: chatMessage.isMe ? AppColors.midBlue : AppColors.darkBlue,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: chatMessage.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              chatMessage.sender,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: Responsive.scaleFont(14, context),
                color: AppColors.lightGray.withOpacity(0.9),
              ),
            ),
            SizedBox(height: AppDimensions.paddingSmall / 2),
            Text(
              chatMessage.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: Responsive.scaleFont(16, context),
                color: AppColors.lightBlue,
              ),
            ),
            SizedBox(height: AppDimensions.paddingSmall / 2),
            Text(
              chatMessage.time,
              style: TextStyle(
                fontSize: Responsive.scaleFont(12, context),
                color: AppColors.lightBlue.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, String sender) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: AppColors.lightGray),
            onPressed: () {
              Get.snackbar('Xabar', 'Fayl yuborish funksiyasi tez kunda qo‘shiladi!',
                  backgroundColor: AppColors.midBlue, colorText: AppColors.lightGray);
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Xabar yozing...',
                hintStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.7)),
                filled: true,
                fillColor: AppColors.darkNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall,
                ),
              ),
              style: TextStyle(color: AppColors.lightGray),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.sendMessage(sender, value);
                  _textController.clear();
                }
              },
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.red,
            child: Icon(Icons.send, color: AppColors.white),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                controller.sendMessage(sender, _textController.text);
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.cardRadius)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.red),
              title: Text(
                'Xabarni o‘chirish',
                style: TextStyle(color: AppColors.lightGray),
              ),
              onTap: () {
                Get.back();
                Get.snackbar('Xabar', 'Xabar o‘chirildi!',
                    backgroundColor: AppColors.midBlue, colorText: AppColors.lightGray);
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.red),
              title: Text(
                'Foydalanuvchini bloklash',
                style: TextStyle(color: AppColors.lightGray),
              ),
              onTap: () {
                Get.back();
                Get.snackbar('Xabar', 'Foydalanuvchi bloklandi!',
                    backgroundColor: AppColors.midBlue, colorText: AppColors.lightGray);
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: AppColors.red),
              title: Text(
                'Shikoyat qilish',
                style: TextStyle(color: AppColors.lightGray),
              ),
              onTap: () {
                Get.back();
                Get.snackbar('Xabar', 'Shikoyat yuborildi!',
                    backgroundColor: AppColors.midBlue, colorText: AppColors.lightGray);
              },
            ),
          ],
        );
      },
    );
  }
}