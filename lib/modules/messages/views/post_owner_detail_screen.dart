import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/chat_rooms.dart';
import '../controllers/messages_controller.dart';

/// Bitta eʼlonga kelgan arizalar roʻyxati.
class PostOwnerDetailScreen extends StatefulWidget {
  const PostOwnerDetailScreen({super.key});

  @override
  State<PostOwnerDetailScreen> createState() => _PostOwnerDetailScreenState();
}

class _PostOwnerDetailScreenState extends State<PostOwnerDetailScreen> {
  late final PostOwnerRoom _postOwnerRoom;
  late final int? _currentUserId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args == null) {
      Get.snackbar('Error', 'Room not found');
      Navigator.of(context).pop();
      return;
    }
    _postOwnerRoom = args as PostOwnerRoom;
    _currentUserId = Get.find<FuncController>().userMe.value.data!.id;
    // Kontroller roʻyxatdan oʻtganiga ishonch hosil qilamiz — natijasi
    // bu ekranda ishlatilmaydi, lekin avvalgi xulq saqlanadi.
    Get.find<MessagesController>();
  }

  @override
  Widget build(BuildContext context) {
    final chatRooms = _postOwnerRoom.chatRooms;

    return AppScreen(
      title: _postOwnerRoom.post.title ?? 'Post',
      child:
          chatRooms.isEmpty
              ? AppEmptyState(
                icon: LucideIcons.inbox,
                title: 'No applications found',
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final room = chatRooms[index];
                  return AppReveal(
                    delay: AppReveal.step(index),
                    child: _ApplicationCard(
                      room: room,
                      currentUserId: _currentUserId,
                    ),
                  );
                },
              ),
    );
  }
}

/// Bitta ariza kartasi.
class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.room, required this.currentUserId});

  final ChatRoom room;
  final int? currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.6);
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    final otherUser = room.user1.id == currentUserId ? room.user2 : room.user1;
    final sender =
        '${otherUser.firstName ?? ''} ${otherUser.lastName ?? ''}'.trim();
    final senderInitial = sender.isNotEmpty ? sender[0].toUpperCase() : '?';
    final preview = room.application.message ?? '';
    final time = _formatTime(room.createdAt);
    final hasResume = room.application.resume != null;
    final hasContent =
        room.application.message != null &&
        room.application.message!.isNotEmpty;
    final status = room.application.status ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.messagesDetail, arguments: room),
          child: Container(
            padding: const EdgeInsets.all(14),
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
                          Flexible(
                            child: Text(
                              sender,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          const SizedBox(width: 7),
                          // Qabul qilingan ariza ikki belgi bilan.
                          Icon(
                            status == 'accepted'
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 15,
                            color:
                                status == 'accepted' ? colors.primary : muted,
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                      if (hasResume) ...[
                        const SizedBox(height: 8),
                        _ResumePreview(resume: room.application.resume!),
                      ],
                      if (hasContent) ...[
                        const SizedBox(height: 8),
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

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Kecha'.tr;
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return createdAt;
    }
  }
}

/// Arizaga biriktirilgan rezyume.
class _ResumePreview extends StatelessWidget {
  const _ResumePreview({required this.resume});

  final dynamic resume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = resume.title ?? 'Resume';
    final firstExperience =
        resume.experience != null && resume.experience!.isNotEmpty
            ? resume.experience![0]
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.fileText, size: 15, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (firstExperience != null)
                  Text(
                    firstExperience.position ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: colors.onSurface.withValues(alpha: 0.6),
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
