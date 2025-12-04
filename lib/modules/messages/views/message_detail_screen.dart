import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/socket_service.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../core/utils/responsive.dart';
import '../../../controllers/funcController.dart';

class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({super.key});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final SocketService _socket = SocketService();
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final dynamic _room;
  late final User _otherUser;
  late final int? _currentUserId;
  late final dynamic _currentUser;

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
    _currentUser = Get.find<FuncController>().userMe.value.data!;
    _otherUser = _room.user1.id == _currentUserId ? _room.user2 : _room.user1;
    // Add resume as file message first
    if (_room.application != null && _room.application.resume != null) {
      _messages.add({
        'resume': _room.application.resume,
        'senderId': _room.application.applicant.id,
        'createdAt': _room.application.createdAt,
        'status': 'sent', // Assume initial status
      });
    }
    // Add initial application message
    if (_room.application != null &&
        _room.application.message != null &&
        _room.application.message.isNotEmpty) {
      _messages.add({
        'content': _room.application.message,
        'senderId': _room.application.applicant.id,
        'createdAt': _room.application.createdAt,
        'status': 'sent', // Assume initial status
      });
    }
    _socket.joinChat(_room.id);
    _socket.onNewMessage(_onNewMessage);
    _socket.onMessageStatus(_onMessageStatus);
    _messages.sort(
      (a, b) => DateTime.parse(
        b['createdAt'],
      ).compareTo(DateTime.parse(a['createdAt'])),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _socket.leaveChat(_room.id);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  String _getDateString(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final difference = today.difference(messageDate).inDays;
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '${messageDate.day}/${messageDate.month}/${messageDate.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }

  Widget _buildDateHeader(BuildContext context, String date) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: AppColors.lightGray,
            fontSize: Responsive.scaleFont(14, context),
          ),
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  void _onNewMessage(Map<String, dynamic> data) {
    setState(() {
      _messages.add(data);
      _messages.sort(
        (a, b) => DateTime.parse(
          b['createdAt'],
        ).compareTo(DateTime.parse(a['createdAt'])),
      );
      _scrollToBottom();
    });
  }

  void _onMessageStatus(Map<String, dynamic> data) {
    setState(() {
      final messageId = data['messageId'];
      final status = data['status'];
      final index = _messages.indexWhere((msg) => msg['id'] == messageId);
      if (index != -1) {
        _messages[index]['status'] = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildChatScreen(context);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkNavy,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.midBlue,
            radius: Responsive.scaleWidth(20, context),
            child: Text(
              _otherUser.firstName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: Responsive.scaleFont(16, context),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              _otherUser.firstName,
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
            Get.snackbar(
              'Xabar',
              'Qo‘ng‘iroq funksiyasi tez kunda qo‘shiladi!',
              backgroundColor: AppColors.midBlue,
              colorText: AppColors.lightGray,
            );
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

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[_messages.length - 1 - index];
              final currentDate = _getDateString(msg['createdAt']);
              final previousDate =
                  index < _messages.length - 1
                      ? _getDateString(
                        _messages[_messages.length -
                            1 -
                            index -
                            1]['createdAt'],
                      )
                      : null;
              final showDate = currentDate != previousDate;
              return Column(
                children: [
                  if (showDate) _buildDateHeader(context, currentDate),
                  _buildMessageBubble(context, msg),
                ],
              );
            },
          ),
        ),
        _buildInputField(context),
      ],
    );
  }

  Widget _buildResumeMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final resume = msg['resume'];
    final isMe = msg['senderId'] == _currentUserId;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                backgroundColor: AppColors.midBlue,
                radius: Responsive.scaleWidth(16, context),
                child: Text(
                  _otherUser.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.paddingSmall),
            ],
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSmall,
                ),
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.midBlue : AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                ),
                child: ListTile(
                  leading: Icon(Icons.file_present, color: AppColors.lightBlue),
                  title: Text(
                    resume.title ?? 'Resume',
                    style: TextStyle(color: AppColors.lightGray),
                  ),
                  onTap: () => _showResumeDialog(context),
                ),
              ),
            ),
            if (isMe) ...[
              SizedBox(width: AppDimensions.paddingSmall),
              CircleAvatar(
                backgroundColor: AppColors.midBlue,
                radius: Responsive.scaleWidth(16, context),
                child: Text(
                  _currentUser.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    if (msg.containsKey('resume')) {
      return _buildResumeMessageBubble(context, msg);
    }
    final isMe = msg['senderId'] == _currentUserId;
    final time = _formatTime(msg['createdAt']);
    final status = msg['status'] ?? 'sent';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                backgroundColor: AppColors.midBlue,
                radius: Responsive.scaleWidth(16, context),
                child: Text(
                  _otherUser.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.paddingSmall),
            ],
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSmall,
                ),
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.midBlue : AppColors.darkBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? AppDimensions.cardRadius : 0),
                    topRight: Radius.circular(AppDimensions.cardRadius),
                    bottomLeft: Radius.circular( AppDimensions.cardRadius,),
                    bottomRight: Radius.circular(isMe ? 0 : AppDimensions.cardRadius)
                  )
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(msg['content'] ?? '', style: TextStyle(color: AppColors.lightGray)),
                    SizedBox(height: AppDimensions.paddingSmall / 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: AppColors.lightBlue.withOpacity(0.7),
                            fontSize: Responsive.scaleFont(12, context),
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: AppDimensions.paddingSmall / 2),
                          Text(
                            status == 'seen'
                                ? 'Seen'
                                : status == 'delivered'
                                ? 'Delivered'
                                : '',
                            style: TextStyle(
                              color:
                                  status == 'seen'
                                      ? AppColors.lightBlue
                                      : AppColors.lightGray.withOpacity(0.7),
                              fontSize: Responsive.scaleFont(10, context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              SizedBox(width: AppDimensions.paddingSmall),
              CircleAvatar(
                backgroundColor: AppColors.midBlue,
                radius: Responsive.scaleWidth(16, context),
                child: Text(
                  _currentUser.firstName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.lightGray,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppDimensions.paddingMedium,
        bottom: AppDimensions.paddingLarge,
        left: 15.sp,
        right: 15.sp,
      ),
      color: AppColors.darkBlue,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: _textController,
                style: TextStyle(color: AppColors.lightGray),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: AppColors.lightBlue.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: AppColors.darkNavy,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: Responsive.scaleHeight(16, context),
                    horizontal: Responsive.scaleWidth(20, context),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Container(
            height: 50,
            width: 60,
            child: ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  final message = {
                    'content': _textController.text,
                    'senderId': _currentUserId,
                    'createdAt': DateTime.now().toIso8601String(),
                    'status': 'sent',
                    'id': DateTime.now().millisecondsSinceEpoch, // Temporary id
                  };
                  setState(() {
                    _messages.add(message);
                    _messages.sort(
                      (a, b) => DateTime.parse(
                        b['createdAt'],
                      ).compareTo(DateTime.parse(a['createdAt'])),
                    );
                    _scrollToBottom();
                  });
                  _socket.sendMessage(
                    chatRoomId: _room.id,
                    content: _textController.text,
                  );
                  _textController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(Icons.send, color: AppColors.lightGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBlue,
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
                'Xabarni o‘chirish',
                style: TextStyle(color: AppColors.lightGray),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Xabar',
                  'Xabar o‘chirildi!',
                  backgroundColor: AppColors.midBlue,
                  colorText: AppColors.lightGray,
                );
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
                Get.snackbar(
                  'Xabar',
                  'Foydalanuvchi bloklandi!',
                  backgroundColor: AppColors.midBlue,
                  colorText: AppColors.lightGray,
                );
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
                Get.snackbar(
                  'Xabar',
                  'Shikoyat yuborildi!',
                  backgroundColor: AppColors.midBlue,
                  colorText: AppColors.lightGray,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showResumeDialog(BuildContext context) {
    final resume = _room.application?.resume;

    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            backgroundColor: AppColors.darkNavy,
            child: Scaffold(
              backgroundColor: AppColors.darkNavy,
              appBar: AppBar(
                backgroundColor: AppColors.darkNavy,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: AppColors.lightGray),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Resume',
                  style: TextStyle(color: AppColors.lightGray),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    // User header card
                    Card(
                      color: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.midBlue,
                              radius: Responsive.scaleWidth(30, context),
                              child: Text(
                                _otherUser.firstName[0].toUpperCase(),
                                style: TextStyle(color: AppColors.lightGray),
                              ),
                            ),
                            SizedBox(width: AppDimensions.paddingMedium),
                            Text(
                              _otherUser.firstName,
                              style: TextStyle(
                                color: AppColors.lightGray,
                                fontSize: Responsive.scaleFont(18, context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // Title card
                    if (resume?.title != null && resume!.title!.isNotEmpty)
                      Card(
                        color: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.title, color: AppColors.lightBlue),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Sarlavha',
                                    style: TextStyle(
                                      color: AppColors.lightBlue,
                                      fontSize: Responsive.scaleFont(
                                        18,
                                        context,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              Text(
                                resume.title!,
                                style: TextStyle(
                                  color: AppColors.lightGray,
                                  fontSize: Responsive.scaleFont(16, context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // Content card
                    if (resume?.content != null && resume!.content!.isNotEmpty)
                      Card(
                        color: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description,
                                    color: AppColors.lightBlue,
                                  ),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Tarkib',
                                    style: TextStyle(
                                      color: AppColors.lightBlue,
                                      fontSize: Responsive.scaleFont(
                                        18,
                                        context,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              Text(
                                resume.content!,
                                style: TextStyle(
                                  color: AppColors.lightGray,
                                  fontSize: Responsive.scaleFont(16, context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // Education card
                    if (resume?.education != null &&
                        resume!.education!.isNotEmpty)
                      Card(
                        color: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.school,
                                    color: AppColors.lightBlue,
                                  ),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Ta\'lim',
                                    style: TextStyle(
                                      color: AppColors.lightBlue,
                                      fontSize: Responsive.scaleFont(
                                        18,
                                        context,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              ...resume.education!.map(
                                (edu) => Container(
                                  margin: EdgeInsets.only(
                                    bottom: AppDimensions.paddingSmall,
                                  ),
                                  padding: EdgeInsets.all(
                                    AppDimensions.paddingSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkNavy,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (edu.degree != null)
                                        Text(
                                          'Daraja: ${edu.degree}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (edu.field != null)
                                        Text(
                                          'Soha: ${edu.field}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (edu.institution != null)
                                        Text(
                                          'Muassasa: ${edu.institution}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (edu.period != null)
                                        Text(
                                          'Davri: ${edu.period}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
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
                    SizedBox(height: AppDimensions.paddingMedium),
                    // Experience card
                    if (resume?.experience != null &&
                        resume!.experience!.isNotEmpty)
                      Card(
                        color: AppColors.darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.cardRadius,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.work, color: AppColors.lightBlue),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Tajriba',
                                    style: TextStyle(
                                      color: AppColors.lightBlue,
                                      fontSize: Responsive.scaleFont(
                                        18,
                                        context,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              ...resume.experience!.map(
                                (exp) => Container(
                                  margin: EdgeInsets.only(
                                    bottom: AppDimensions.paddingSmall,
                                  ),
                                  padding: EdgeInsets.all(
                                    AppDimensions.paddingSmall,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkNavy,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.cardRadius,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (exp.position != null)
                                        Text(
                                          'Lavozim: ${exp.position}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (exp.company != null)
                                        Text(
                                          'Kompaniya: ${exp.company}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (exp.period != null)
                                        Text(
                                          'Davri: ${exp.period}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
                                          ),
                                        ),
                                      if (exp.description != null)
                                        Text(
                                          'Tavsif: ${exp.description}',
                                          style: TextStyle(
                                            color: AppColors.lightGray,
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
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
