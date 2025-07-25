import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/models/message_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/messages_controller.dart';

class MessagesScreen extends GetView<MessagesController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: _buildAppBar(context),
      body: _buildBody(context)
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkNavy,
      elevation: 0,
      title: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: TextField(
          onChanged: (value) => controller.filterMessages(value),
          style: TextStyle(color: AppColors.lightGray),
          decoration: InputDecoration(
            hintText: 'Xabarni qidiring...',
            hintStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.7)),
            prefixIcon: Icon(Icons.search, color: AppColors.lightGray),
            fillColor: AppColors.darkBlue,
            suffixIcon: controller.searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: AppColors.lightGray), onPressed: () {},) : null,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              borderSide: BorderSide(color: AppColors.lightBlue, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      return controller.filteredMessages.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: controller.filteredMessages.length,
        itemBuilder: (context, index) {
          return _buildMessageCard(context, controller.filteredMessages[index]);
        },
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: AppDimensions.iconSizeLarge,
            color: AppColors.lightBlue.withOpacity(0.3),
          ),
          SizedBox(height: AppDimensions.paddingMedium),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'Qidiruv bo‘yicha xabar topilmadi'
                : 'Hozircha xabarlar yo‘q',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: Responsive.scaleFont(18, context),
              color: AppColors.lightBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Yangi xabar yozish uchun pastdagi tugmani bosing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: Responsive.scaleFont(14, context),
              color: AppColors.lightBlue.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, Message message) {
    return Card(
      color: AppColors.darkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.midBlue,
          child: Text(
            message.sender[0].toUpperCase(),
            style: TextStyle(color: AppColors.lightGray),
          ),
        ),
        title: Text(
          message.sender,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: Responsive.scaleFont(16, context),
          ),
        ),
        subtitle: Text(
          message.preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: Responsive.scaleFont(14, context),
            color: AppColors.lightBlue.withOpacity(0.8),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message.time,
              style: TextStyle(
                fontSize: Responsive.scaleFont(12, context),
                color: AppColors.lightBlue,
              ),
            ),
            if (message.unreadCount > 0)
              Container(
                margin: EdgeInsets.only(top: AppDimensions.paddingSmall),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${message.unreadCount}',
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(12, context),
                    color: AppColors.white,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          Get.toNamed('/messages_detail', arguments: message);
        },
      ),
    );
  }
}