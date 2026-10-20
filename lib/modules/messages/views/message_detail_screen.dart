import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:get/get.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/socket_service.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../core/services/show_toast.dart';
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
      Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          date,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colors.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
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

  /// Suhbatdosh nomi va harfli avatar. Panel uslubi mavzudan keladi.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      titleSpacing: 4,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            child: Text(
              (_otherUser.firstName?.isNotEmpty ?? false)
                  ? _otherUser.firstName![0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              _otherUser.firstName ?? 'User',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 2,
          ),
        ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final resume = msg['resume'];
    final isMe = msg['senderId'] == _currentUserId;
    final time = _formatTime(msg['createdAt']);
    final status = msg['status'] ?? 'sent';

    // Colors based on sender
    final cardColor =
        isMe ? colors.primary : colors.onSurface.withValues(alpha: 0.05);
    final titleColor = isMe ? colors.onPrimary : colors.onSurface;
    final subtitleColor = titleColor.withValues(alpha: 0.6);
    final iconColor = isMe ? colors.onPrimary : colors.primary;
    final timeColor = titleColor.withValues(alpha: 0.6);
    final borderColor = titleColor.withValues(alpha: 0.12);
    final headerColor = titleColor.withValues(alpha: 0.06);

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

    // "Dumcha" tomonidagi burchak kichikroq — matnli pufak bilan bir xil.
    final radius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 18 : 6),
      topRight: Radius.circular(isMe ? 6 : 18),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showResumeDialog(context),
                splashColor: titleColor.withValues(alpha: 0.06),
                highlightColor: titleColor.withValues(alpha: 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with user info and resume icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: headerColor,
                      child: Row(
                        children: [
                          // User avatar
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: iconColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // User name
                          Expanded(
                            child: Text(
                              '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                  .trim(),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: titleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Resume icon
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              LucideIcons.fileText,
                              color: iconColor,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Resume title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        resume?.title ?? 'Rezyume'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Experience preview
                    if (firstExperience != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.briefcase,
                              color: subtitleColor,
                              size: 14,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                firstExperience.position ?? '',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],

                    // Education preview
                    if (firstEducation != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.graduationCap,
                              color: subtitleColor,
                              size: 14,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                firstEducation.degree ?? '',
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 12.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Footer with time, status and tap hint
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 11),
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
                                  fontSize: 11,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 5),
                                // Holat belgisi almashganda yumshoq oʼtish.
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  transitionBuilder:
                                      (child, animation) => FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      ),
                                  child: Icon(
                                    status == 'seen'
                                        ? Icons.done_all
                                        : Icons.done,
                                    key: ValueKey(status == 'seen'),
                                    color:
                                        status == 'seen'
                                            ? titleColor
                                            : timeColor,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Tap to view hint
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ko‘rish'.tr,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                LucideIcons.chevronRight,
                                color: subtitleColor,
                                size: 13,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isMe = msg['senderId'] == _currentUserId;
    final time = _formatTime(msg['createdAt']);
    final status = msg['status'] ?? 'sent';

    final bubbleColor =
        isMe ? colors.primary : colors.onSurface.withValues(alpha: 0.05);
    final bubbleTextColor = isMe ? colors.onPrimary : colors.onSurface;
    final timeColor = bubbleTextColor.withValues(alpha: 0.6);
    // "Dumcha" tomonidagi burchak kichikroq — shakl qatʼiy 0 emas,
    // yumshoq boʼlib qoladi.
    final radius = BorderRadius.only(
      topLeft: Radius.circular(isMe ? 18 : 6),
      topRight: Radius.circular(isMe ? 6 : 18),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Material(
            color: bubbleColor,
            borderRadius: radius,
            child: InkWell(
              key: bubbleKey,
              onLongPress: () {
                if (isMe) {
                  _showMessageOptions(context, msg, bubbleKey);
                }
              },
              borderRadius: radius,
              splashColor: bubbleTextColor.withValues(alpha: 0.06),
              highlightColor: bubbleTextColor.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg['content'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: bubbleTextColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(color: timeColor, fontSize: 11),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 5),
                          // Holat belgisi almashganda yumshoq oʼtish.
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            transitionBuilder:
                                (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                            child: Icon(
                              status == 'seen' ? Icons.done_all : Icons.done,
                              key: ValueKey(status == 'seen'),
                              color:
                                  status == 'seen'
                                      ? bubbleTextColor
                                      : timeColor,
                              size: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isEditing = _editingMessageId != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit panel (shown only when editing)
        // Tahrirlash paneli yumshoq ochilib-yopiladi.
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child:
              !isEditing
                  ? const SizedBox(width: double.infinity)
                  : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusControl,
                      ),
                      border: Border(
                        left: BorderSide(color: colors.primary, width: 2.5),
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
                                  LucideIcons.pencil,
                                  color: colors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Xabarni tahrirlash'.tr,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
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
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                LucideIcons.x,
                                color: colors.onSurface.withValues(alpha: 0.5),
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Message preview
                        Text(
                          _messages.firstWhere(
                                (msg) => msg['id'] == _editingMessageId,
                                orElse: () => {'content': ''},
                              )['content'] ??
                              '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
        // Input field container
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
          decoration: BoxDecoration(
            color: colors.surface,
            // Panel mazmundan nozik chiziq bilan ajraladi.
            border: Border(
              top: BorderSide(
                color: colors.onSurface.withValues(alpha: 0.07),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // Bezak mavzudagi `inputDecorationTheme` dan keladi.
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText:
                        isEditing
                            ? 'Xabarni tahrirlash'.tr
                            : 'Xabar yozing...'.tr,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isEditing) ...[
                // Update button
                _SendButton(
                  icon: LucideIcons.check,
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty && !_isSending) {
                      final messageContent = _textController.text.trim();
                      if (messageContent.isEmpty) return;

                      setState(() {
                        _isSending = true;
                      });

                      _updateMessage(_editingMessageId!, messageContent).then((
                        _,
                      ) {
                        setState(() {
                          _editingMessageId = null;
                          _textController.clear();
                          _isSending = false;
                        });
                      });
                    }
                  },
                ),
              ] else ...[
                // Send button (normal mode)
                _SendButton(
                  icon: LucideIcons.send,
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
                        if (!mounted) return;
                        setState(() {
                          _isSending = false;
                        });
                      });
                    }
                  },
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
      // Yuza va radius mavzudan keladi.
      color: Theme.of(context).colorScheme.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          height: 46,
          child: Row(
            children: [
              Icon(
                LucideIcons.pencil,
                color: Theme.of(context).colorScheme.primary,
                size: 17,
              ),
              const SizedBox(width: 12),
              Text(
                'Xabarni tahrirlash'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 46,
          child: Row(
            children: [
              Icon(
                LucideIcons.trash2,
                color: Theme.of(context).colorScheme.error,
                size: 17,
              ),
              const SizedBox(width: 12),
              Text(
                'Xabarni o\'chirish'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
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
          top: Radius.circular(AppTheme.radiusSheet),
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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

    showDialog(
      context: context,
      builder:
          (context) => Dialog.fullscreen(
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final colors = theme.colorScheme;
                final sections = <Widget>[];

                // User header card
                sections.add(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.035),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors.primary.withValues(
                            alpha: 0.14,
                          ),
                          radius: 26,
                          child: Text(
                            (_otherUser.firstName?.isNotEmpty ?? false)
                                ? _otherUser.firstName![0].toUpperCase()
                                : 'U',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _otherUser.firstName ?? 'User',
                            style: theme.textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                // Title card
                if (resume?.title != null && resume!.title!.isNotEmpty) {
                  sections.add(
                    _ResumeSection(
                      icon: LucideIcons.type,
                      title: 'Sarlavha'.tr,
                      children: [
                        Text(resume.title!, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  );
                }

                // Content card
                if (resume?.content != null && resume!.content!.isNotEmpty) {
                  sections.add(
                    _ResumeSection(
                      icon: LucideIcons.fileText,
                      title: 'Tarkib'.tr,
                      children: [
                        Text(
                          resume.content!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Education card
                if (resume?.education != null &&
                    resume!.education!.isNotEmpty) {
                  sections.add(
                    _ResumeSection(
                      icon: LucideIcons.graduationCap,
                      title: 'Ta\u2019lim'.tr,
                      children:
                          resume.education!
                              .map(
                                (edu) => _ResumeEntry(
                                  rows: [
                                    if (edu.degree != null)
                                      ('Daraja'.tr, edu.degree!),
                                    if (edu.field != null)
                                      ('Soha'.tr, edu.field!),
                                    if (edu.institution != null)
                                      ('Muassasa'.tr, edu.institution!),
                                    if (edu.period != null)
                                      ('Davri'.tr, edu.period!),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  );
                }

                // Experience card
                if (resume?.experience != null &&
                    resume!.experience!.isNotEmpty) {
                  sections.add(
                    _ResumeSection(
                      icon: LucideIcons.briefcase,
                      title: 'Tajriba'.tr,
                      children:
                          resume.experience!
                              .map(
                                (exp) => _ResumeEntry(
                                  rows: [
                                    if (exp.position != null)
                                      ('Lavozim'.tr, exp.position!),
                                    if (exp.company != null)
                                      ('Kompaniya'.tr, exp.company!),
                                    if (exp.period != null)
                                      ('Davri'.tr, exp.period!),
                                    if (exp.description != null)
                                      ('Tavsif'.tr, exp.description!),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  );
                }

                return Scaffold(
                  // Panel uslubi mavzudan keladi.
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text('Rezyume'.tr),
                  ),
                  body: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: sections.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    // Bo\u2018limlar ketma-ket, yumshoq ko\u2018tarilib chiqadi.
                    itemBuilder:
                        (context, index) => AppReveal(
                          delay: AppReveal.step(index),
                          child: sections[index],
                        ),
                  ),
                );
              },
            ),
          ),
    );
  }
}

/// Rezyume oynasidagi bitta bo\u2018lim kartasi.
class _ResumeSection extends StatelessWidget {
  const _ResumeSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: colors.primary),
              const SizedBox(width: 9),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Bo\u2018lim ichidagi bitta yozuv (ta\u2019lim yoki tajriba).
class _ResumeEntry extends StatelessWidget {
  const _ResumeEntry({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(AppTheme.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  children: [
                    TextSpan(
                      text: '${row.$1}: ',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    TextSpan(text: row.$2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Yuborish / saqlash tugmasi — bosilganda yengil kichrayadi.
class _SendButton extends StatefulWidget {
  const _SendButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Material(
        color: colors.primary,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(widget.icon, color: colors.onPrimary, size: 19),
          ),
        ),
      ),
    );
  }
}
