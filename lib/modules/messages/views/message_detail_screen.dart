import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/socket_service.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../core/services/show_toast.dart';
import '../../../core/utils/responsive.dart';
import '../../../controllers/funcController.dart';

class MessageDetailScreen extends StatefulWidget {
  const MessageDetailScreen({super.key});

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  final SocketService _socketService = SocketService();
  final ApiController _apiController = Get.find<ApiController>();
  final FuncController _funcController = Get.find<FuncController>();
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<int> _processedMessageIds = <int>{};
  late final dynamic _room;
  late final User _otherUser;
  late final int? _currentUserId;
  late final dynamic _currentUser;
  bool _isLoading = true;
  bool _listenersRegistered = false;
  bool _isSending = false;
  int? _editingMessageId; // Tahrirlanayotgan xabar ID si

  @override
  void initState() {
    super.initState();
    _room = Get.arguments;
    if (_room == null) {
      Get.snackbar('Error', 'Room not found');
      Get.back();
      return;
    }
    _currentUserId = _funcController.userMe.value.data!.id;
    _currentUser = _funcController.userMe.value.data!;
    _otherUser = _room.user1.id == _currentUserId ? _room.user2 : _room.user1;

    _setupSocketConnection();
    _loadMessages();
  }

  void _setupSocketConnection() {
    final token = _funcController.getToken();
    if (token != null && token.isNotEmpty) {
      // Connect to socket if not already connected
      if (!_socketService.isConnected) {
        _socketService.connect(token: token);
      }

      // Only register listeners once
      if (!_listenersRegistered) {
        // Listen for new messages
        _socketService.onNewMessage(_onNewMessage);

        // Listen for message status updates
        _socketService.onMessageStatus(_onMessageStatus);

        _listenersRegistered = true;
      }

      // Join the chat room
      _socketService.joinChat(_room.id);

      // Update presence to online
      _socketService.updatePresence(true);
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch messages from API
      final response = await _apiController.fetchChatRoomMessages(_room.id);

      // Convert API messages to the format used by the screen
      final apiMessages =
          response.data.map((msg) {
            return {
              'id': msg.id,
              'content': msg.content,
              'senderId': msg.sender.id,
              'createdAt': msg.createdAt.toIso8601String(),
              'status': msg.isRead ? 'seen' : 'delivered',
              'mediaUrl': msg.mediaUrl,
              'resume': msg.resume,
            };
          }).toList();

      setState(() {
        _messages.clear();
        _processedMessageIds.clear();
        _messages.addAll(apiMessages);
        // Add initial message IDs to processed set
        for (final msg in apiMessages) {
          final msgId = msg['id'];
          if (msgId is int) {
            _processedMessageIds.add(msgId);
          }
        }
        _isLoading = false;
      });

      // Sort messages in ascending order (oldest first) for reverse ListView
      _messages.sort(
        (a, b) => DateTime.parse(
          a['createdAt'],
        ).compareTo(DateTime.parse(b['createdAt'])),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      debugPrint('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
      ShowToast.show('Xatolik', 'Xabarlar yuklashda xatolik yuz berdi', 3, 1);
    }
  }

  @override
  void dispose() {
    // Leave the chat room
    _socketService.leaveChat(_room.id);
    // Update presence to offline when leaving chat
    _socketService.updatePresence(false);
    // Remove listeners to prevent duplicates
    if (_listenersRegistered) {
      _socketService.removeNewMessageListener(_onNewMessage);
      _socketService.removeMessageStatusListener(_onMessageStatus);
      _listenersRegistered = false;
    }
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
        return 'Bugun'.tr;
      } else if (difference == 1) {
        return 'Kecha'.tr;
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
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        child: Text(
          date,
          style: TextStyle(
            color: AppColors.textColor,
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
    // Extract message ID
    final messageId = data['id'] ?? data['messageId'];

    // Check if message ID is valid and is an integer
    if (messageId == null || messageId is! int) {
      return;
    }

    // Check if message was already processed to prevent duplicates
    if (_processedMessageIds.contains(messageId)) {
      return; // Skip duplicate messages
    }

    // Mark message as processed
    _processedMessageIds.add(messageId);

    // Convert socket message data to the format used by the screen
    final message = {
      'id': messageId,
      'content': data['content'] ?? '',
      'senderId': data['senderId'] ?? data['sender']?['id'],
      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      'status': data['status'] ?? 'sent',
      'mediaUrl': data['mediaUrl'],
      'resume': data['resume'],
    };

    setState(() {
      _messages.add(message);
      // Sort messages in ascending order (oldest first) for reverse ListView
      _messages.sort(
        (a, b) => DateTime.parse(
          a['createdAt'],
        ).compareTo(DateTime.parse(b['createdAt'])),
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
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      surfaceTintColor: AppColors.backgroundColor,
      shadowColor: AppColors.backgroundColor,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: Responsive.scaleWidth(20, context),
            child: Text(
              (_otherUser.firstName?.isNotEmpty ?? false)
                  ? _otherUser.firstName![0].toUpperCase()
                  : 'U',
              style: TextStyle(
                color: AppColors.white,
                fontSize: Responsive.scaleFont(16, context),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              _otherUser.firstName ?? 'User',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: Responsive.scaleFont(18, context),
                color: AppColors.textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textColor),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

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

  Widget _buildResumeMessageBubble(
    BuildContext context,
    Map<String, dynamic> msg,
  ) {
    final resume = msg['resume'];
    final isMe = msg['senderId'] == _currentUserId;
    final time = _formatTime(msg['createdAt']);
    final status = msg['status'] ?? 'sent';

    // Colors based on sender
    final cardColor = isMe ? AppColors.primaryColor : AppColors.cardColor;
    final titleColor = isMe ? AppColors.white : AppColors.textColor;
    const subtitleColor = Color(0xFFB8B8B8);
    final iconColor =
        isMe ? AppColors.white.withOpacity(0.8) : AppColors.primaryColor;
    final timeColor =
        isMe
            ? AppColors.white.withOpacity(0.7)
            : AppColors.iconColor.withOpacity(0.7);
    final borderColor =
        isMe ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2);
    final backgroundColor =
        isMe
            ? AppColors.primaryColor.withOpacity(0.15)
            : AppColors.backgroundColor;

    // Get user initials
    final user = isMe ? _currentUser : _otherUser;
    final firstNameInitial =
        (user.firstName?.isNotEmpty ?? false) ? user.firstName![0] : 'U';
    final lastNameInitial =
        (user.lastName?.isNotEmpty ?? false) ? user.lastName![0] : '';
    final initials = (firstNameInitial + lastNameInitial).toUpperCase();

    // Get experience preview
    final firstExperience =
        resume?.experience != null && resume!.experience!.isNotEmpty
            ? resume.experience![0]
            : null;

    // Get education preview
    final firstEducation =
        resume?.education != null && resume!.education!.isNotEmpty
            ? resume.education![0]
            : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () => _showResumeDialog(context),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        isMe ? AppDimensions.cardRadius : 0,
                      ),
                      topRight: Radius.circular(
                        isMe ? 0 : AppDimensions.cardRadius,
                      ),
                      bottomLeft: Radius.circular(AppDimensions.cardRadius),
                      bottomRight: Radius.circular(AppDimensions.cardRadius),
                    ),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with user info and resume icon
                      Container(
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              isMe ? AppDimensions.cardRadius - 1 : 0,
                            ),
                            topRight: Radius.circular(
                              isMe ? 0 : AppDimensions.cardRadius - 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // User avatar
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: iconColor,
                                    fontSize: Responsive.scaleFont(14, context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppDimensions.paddingSmall),
                            // User name
                            Expanded(
                              child: Text(
                                '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                    .trim(),
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: Responsive.scaleFont(14, context),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Resume icon
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                color: iconColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Resume title
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingSmall,
                        ),
                        child: Text(
                          resume?.title ?? 'Resume',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: Responsive.scaleFont(16, context),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Experience preview
                      if (firstExperience != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.work_outline,
                                color: subtitleColor,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  firstExperience.position ?? '',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: Responsive.scaleFont(13, context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                      ],

                      // Education preview
                      if (firstEducation != null) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                color: subtitleColor,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  firstEducation.degree ?? '',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: Responsive.scaleFont(13, context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppDimensions.paddingSmall),
                      ],

                      // Footer with time, status and tap hint
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingSmall,
                          AppDimensions.paddingMedium,
                          AppDimensions.paddingMedium,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time and status
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: timeColor,
                                    fontSize: Responsive.scaleFont(11, context),
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 4),
                                  if (status == 'seen')
                                    Icon(
                                      Icons.done_all,
                                      color: AppColors.white,
                                      size: Responsive.scaleFont(14, context),
                                    )
                                  else
                                    Icon(
                                      Icons.done,
                                      color: AppColors.white.withOpacity(0.7),
                                      size: Responsive.scaleFont(14, context),
                                    ),
                                ],
                              ],
                            ),
                            // Tap to view hint
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tap to view',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: Responsive.scaleFont(11, context),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: subtitleColor,
                                  size: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> msg) {
    final isMe = msg['senderId'] == _currentUserId;
    final GlobalKey bubbleKey = GlobalKey();

    // Check if message has resume
    final hasResume = msg.containsKey('resume') && msg['resume'] != null;
    // Check if message has content text
    final hasContent = msg['content'] != null && msg['content']!.isNotEmpty;

    // If message has both resume and content, display both
    if (hasResume && hasContent) {
      return Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _buildResumeMessageBubble(context, msg),
          SizedBox(height: AppDimensions.paddingSmall),
          _buildTextMessageBubble(context, msg, bubbleKey),
        ],
      );
    }

    // If message has only resume, display resume bubble
    if (hasResume) {
      return _buildResumeMessageBubble(context, msg);
    }

    // Otherwise, display regular text message
    return _buildTextMessageBubble(context, msg, bubbleKey);
  }

  Widget _buildTextMessageBubble(
    BuildContext context,
    Map<String, dynamic> msg,
    GlobalKey bubbleKey,
  ) {
    final isMe = msg['senderId'] == _currentUserId;
    final time = _formatTime(msg['createdAt']);
    final status = msg['status'] ?? 'sent';
    final bubbleTextColor = isMe ? AppColors.white : AppColors.textColor;
    final timeColor =
        isMe
            ? AppColors.white.withOpacity(0.7)
            : AppColors.iconColor.withOpacity(0.7);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GestureDetector(
                key: bubbleKey,
                onLongPress: () {
                  if (isMe) {
                    _showMessageOptions(context, msg, bubbleKey);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingSmall,
                  ),
                  padding: EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primaryColor : AppColors.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        isMe ? AppDimensions.cardRadius : 0,
                      ),
                      topRight: Radius.circular(
                        isMe ? 0 : AppDimensions.cardRadius,
                      ),
                      bottomLeft: Radius.circular(AppDimensions.cardRadius),
                      bottomRight: Radius.circular(AppDimensions.cardRadius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['content'] ?? '',
                        style: TextStyle(color: bubbleTextColor),
                      ),
                      SizedBox(height: AppDimensions.paddingSmall / 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              color: timeColor,
                              fontSize: Responsive.scaleFont(12, context),
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: AppDimensions.paddingSmall / 2),
                            if (status == 'seen')
                              Icon(
                                Icons.done_all,
                                color: AppColors.white,
                                size: Responsive.scaleFont(14, context),
                              )
                            else
                              Icon(
                                Icons.done,
                                color: AppColors.white.withOpacity(0.7),
                                size: Responsive.scaleFont(14, context),
                              ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final isEditing = _editingMessageId != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit panel (shown only when editing)
        if (isEditing) ...[
          Container(
            margin: EdgeInsets.only(
              bottom: AppDimensions.paddingSmall,
              left: 15.sp,
              right: 15.sp,
            ),
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Xabarni tahrirlash',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: Responsive.scaleFont(14, context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _editingMessageId = null;
                          _textController.clear();
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.textColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                // Message preview
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius / 2,
                    ),
                  ),
                  child: Text(
                    _messages.firstWhere(
                          (msg) => msg['id'] == _editingMessageId,
                          orElse: () => {'content': ''},
                        )['content'] ??
                        '',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(13, context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Input field container
        Container(
          padding: EdgeInsets.only(
            top: AppDimensions.paddingMedium,
            bottom: AppDimensions.paddingLarge,
            left: 15.sp,
            right: 15.sp,
          ),
          color: AppColors.cardColor,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      hintText:
                          isEditing ? 'Xabarni tahrirlash' : 'Type a message',
                      hintStyle: TextStyle(
                        color: AppColors.iconColor.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
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
              if (isEditing) ...[
                // Update button
                Container(
                  height: 50,
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_textController.text.trim().isNotEmpty &&
                          !_isSending) {
                        final messageContent = _textController.text.trim();
                        if (messageContent.isEmpty) return;

                        setState(() {
                          _isSending = true;
                        });

                        _updateMessage(_editingMessageId!, messageContent).then(
                          (_) {
                            setState(() {
                              _editingMessageId = null;
                              _textController.clear();
                              _isSending = false;
                            });
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.send, color: AppColors.textColor),
                  ),
                ),
              ] else ...[
                // Send button (normal mode)
                Container(
                  height: 50,
                  width: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty && !_isSending) {
                        final messageContent = _textController.text.trim();
                        if (messageContent.isEmpty) return;

                        setState(() {
                          _isSending = true;
                        });

                        _textController.clear();

                        // Send message via socket for real-time delivery
                        _socketService.sendMessage(
                          chatRoomId: _room.id,
                          content: messageContent,
                        );

                        // Reset sending flag after a short delay
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            _isSending = false;
                          });
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Icon(Icons.send, color: AppColors.textColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'delete':
        Get.snackbar(
          'Xabar',
          'Xabar o\'chirildi!',
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.textColor,
        );
        break;
      case 'block':
        Get.snackbar(
          'Xabar',
          'Foydalanuvchi bloklandi!',
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.textColor,
        );
        break;
      case 'report':
        Get.snackbar(
          'Xabar',
          'Shikoyat yuborildi!',
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.textColor,
        );
        break;
    }
  }

  void _showMessageOptions(
    BuildContext context,
    Map<String, dynamic> msg,
    GlobalKey bubbleKey,
  ) {
    final RenderBox? renderBox =
        bubbleKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      color: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: AppColors.primaryColor, size: 20),
              SizedBox(width: 12),
              Text(
                'Xabarni tahrirlash',
                style: TextStyle(color: AppColors.textColor),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: AppColors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Xabarni o\'chirish',
                style: TextStyle(color: AppColors.textColor),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        _editMessage(msg);
      } else if (value == 'delete') {
        _deleteMessage(msg);
      }
    });
  }

  void _editMessage(Map<String, dynamic> msg) {
    setState(() {
      _editingMessageId = msg['id'];
      _textController.text = msg['content'] ?? '';
    });
    _scrollToBottom();
  }

  Future<void> _updateMessage(int messageId, String newContent) async {
    try {
      final response = await _apiController.updateMessage(
        messageId,
        newContent,
      );

      if (response['success'] == true) {
        setState(() {
          final index = _messages.indexWhere((msg) => msg['id'] == messageId);
          if (index != -1) {
            _messages[index]['content'] = newContent;
          }
        });
        ShowToast.show('Muvaffaqiyat', 'Xabar tahrirlandi', 3, 1);
      } else {
        ShowToast.show(
          'Xatolik',
          'Xabarni tahrirlashda xatolik yuz berdi',
          3,
          1,
        );
      }
    } catch (e) {
      debugPrint('Error updating message: $e');
      ShowToast.show('Xatolik', 'Xabarni tahrirlashda xatolik yuz berdi', 3, 1);
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> msg) async {
    try {
      final response = await _apiController.deleteMessage(msg['id']);

      if (response['success'] == true) {
        setState(() {
          _messages.removeWhere((m) => m['id'] == msg['id']);
        });
        ShowToast.show('Muvaffaqiyat', 'Xabar o\'chirildi', 3, 1);
      } else {
        ShowToast.show(
          'Xatolik',
          'Xabarni o\'chirishda xatolik yuz berdi',
          3,
          1,
        );
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      ShowToast.show('Xatolik', 'Xabarni o\'chirishda xatolik yuz berdi', 3, 1);
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
            SizedBox(height: AppDimensions.paddingLarge),
          ],
        );
      },
    );
  }

  void _showResumeDialog(BuildContext context) {
    final resume = _room.application?.resume;
    final avatarTextColor = AppColors.white;

    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            backgroundColor: AppColors.backgroundColor,
            child: Scaffold(
              backgroundColor: AppColors.backgroundColor,
              appBar: AppBar(
                backgroundColor: AppColors.backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: AppColors.textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Resume',
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    // User header card
                    Card(
                      color: AppColors.cardColor,
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
                              backgroundColor: AppColors.primaryColor,
                              radius: Responsive.scaleWidth(30, context),
                              child: Text(
                                (_otherUser.firstName?.isNotEmpty ?? false)
                                    ? _otherUser.firstName![0].toUpperCase()
                                    : 'U',
                                style: TextStyle(color: avatarTextColor),
                              ),
                            ),
                            SizedBox(width: AppDimensions.paddingMedium),
                            Text(
                              _otherUser.firstName ?? 'User',
                              style: TextStyle(
                                color: AppColors.textColor,
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
                        color: AppColors.cardColor,
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
                                  Icon(Icons.title, color: AppColors.iconColor),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Sarlavha',
                                    style: TextStyle(
                                      color: AppColors.iconColor,
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
                                  color: AppColors.textColor,
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
                        color: AppColors.cardColor,
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
                                    color: AppColors.iconColor,
                                  ),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Tarkib',
                                    style: TextStyle(
                                      color: AppColors.iconColor,
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
                                  color: AppColors.textColor,
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
                        color: AppColors.cardColor,
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
                                    color: AppColors.iconColor,
                                  ),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Ta’lim',
                                    style: TextStyle(
                                      color: AppColors.iconColor,
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
                                    color: AppColors.backgroundColor,
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
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (edu.field != null)
                                        Text(
                                          'Soha: ${edu.field}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (edu.institution != null)
                                        Text(
                                          'Muassasa: ${edu.institution}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (edu.period != null)
                                        Text(
                                          'Davri: ${edu.period}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
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
                        color: AppColors.cardColor,
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
                                  Icon(Icons.work, color: AppColors.iconColor),
                                  SizedBox(width: AppDimensions.paddingSmall),
                                  Text(
                                    'Tajriba',
                                    style: TextStyle(
                                      color: AppColors.iconColor,
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
                                    color: AppColors.backgroundColor,
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
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (exp.company != null)
                                        Text(
                                          'Kompaniya: ${exp.company}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (exp.period != null)
                                        Text(
                                          'Davri: ${exp.period}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      if (exp.description != null)
                                        Text(
                                          'Tavsif: ${exp.description}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
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
