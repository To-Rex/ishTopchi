import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:ishtopchi/common/widgets/map_launcher_bottom_sheet.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:ishtopchi/modules/profile/views/create_resume_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailScreen extends StatefulWidget {
  final PostInterface post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with TickerProviderStateMixin {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final ThemeController themeController = Get.find<ThemeController>();
  late final PostDetailController controller;
  late final AnimatedMapController mapController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostDetailController());
    mapController = AnimatedMapController(vsync: this);
    final latitude =
        widget.post.location?.latitude is String
            ? double.tryParse(widget.post.location!.latitude!)
            : widget.post.location?.latitude as double?;
    final longitude =
        widget.post.location?.longitude is String
            ? double.tryParse(widget.post.location!.longitude!)
            : widget.post.location?.longitude as double?;
    if (latitude != null && longitude != null) {
      controller.setInitialLocation(LatLng(latitude, longitude));
    }
    ApiController().fetchPostById(widget.post.id!.toInt());
  }

  @override
  void dispose() {
    mapController.dispose();
    Get.delete<PostDetailController>();
    super.dispose();
  }

  void _showComplaintDialog(
    BuildContext context,
    ApiController apiController,
    int postId,
  ) {
    final TextEditingController complaintController = TextEditingController();

    Get.dialog(
      _DialogShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder:
                  (context) => Text(
                    'Shikoyat qilish'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
            ),
            const SizedBox(height: 14),
            // Shikoyat matnini yozish
            TextField(
              controller: complaintController,
              maxLines: 4,
              maxLength: 500,
              // Chegara, toʼldirish va matn uslubi mavzudan keladi.
              decoration: InputDecoration(
                hintText: 'Shikoyat matnini kiriting'.tr,
              ),
            ),
            const SizedBox(height: 6),
            // Tugmalar
            _DialogActions(
              cancelLabel: 'Bekor qilish'.tr,
              onCancel: () => Navigator.of(context, rootNavigator: true).pop(),
              confirmLabel: 'Yuborish'.tr,
              onConfirm: () async {
                Navigator.of(context, rootNavigator: true).pop();
                if (complaintController.text.trim().isEmpty) {
                  ShowToast.show(
                    'Xatolik'.tr,
                    'Iltimos, shikoyat matnini kiriting'.tr,
                    1,
                    1,
                  );
                  return;
                }
                // Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginPromptDialog(BuildContext context) {
    Get.dialog(
      _DialogShell(
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.lock,
                    size: 24,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                // Sarlavha
                Text(
                  'Ro‘yxatdan o‘tish talab qilinadi'.tr,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                // Tavsif
                Text(
                  'To‘liq funksiyalardan foydalanish uchun ro‘yxatdan o‘ting yoki hisobingizga kiring.'
                      .tr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                // Tugmalar
                _DialogActions(
                  cancelLabel: 'Bekor qilish'.tr,
                  onCancel:
                      () => Navigator.of(context, rootNavigator: true).pop(),
                  confirmLabel: 'Kirish'.tr,
                  onConfirm: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Get.offNamed('/login');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showApplicationDialog(
    BuildContext context,
    ApiController apiController,
    int postId,
  ) {
    final FuncController funcController = Get.find<FuncController>();
    final TextEditingController messageController = TextEditingController();
    final RxInt selectedResumeId = (-1).obs; // Tanlangan resume IDsi
    final ScrollController scrollController = ScrollController();
    final GlobalKey messageFieldKey = GlobalKey();
    final RxBool isLoading = true.obs; // Local loading flag - starts as true
    final RxBool hasLoaded =
        false.obs; // Flag to track if initial load completed

    // Resumelarni faqat bir marta olish - dialog ochilgandan keyin
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!hasLoaded.value) {
        hasLoaded.value = true;
        await apiController.fetchMeResumes(page: 1, limit: 100);
        isLoading.value = false;
      }
    });

    Get.dialog(
      _DialogShell(
        maxHeightFactor: 0.85,
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sarlavha va tugma
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Murojaat qilish'.tr,
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed:
                            () =>
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(),
                        icon: Icon(
                          LucideIcons.x,
                          color: colors.onSurface.withValues(alpha: 0.55),
                          size: 19,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Resume tanlash
                  Obx(() {
                    // Show loading state while loading or when hasn't loaded yet
                    if (isLoading.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 44),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: colors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Rezyumelar yuklanmoqda...'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    // Show empty state only after loading is complete and resumes are empty
                    if (funcController.resumes.isEmpty && hasLoaded.value) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 28,
                        ),
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.035),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusCard,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.fileText,
                                size: 22,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Rezyumelar mavjud emas'.tr,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Murojaat qilish uchun rezyume yaratishingiz kerak'
                                  .tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.55),
                                height: 1.45,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            AppButton(
                              label: 'Yangi rezyume qo‘shish'.tr,
                              leading: const Icon(LucideIcons.plus),
                              filled: true,
                              onPressed: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    Get.to(() => CreateResumeScreen());
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rezyume ro‘yxati sarlavhasi
                          Row(
                            children: [
                              Icon(
                                LucideIcons.fileText,
                                size: 15,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rezyume tanlang'.tr,
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${funcController.resumes.length}',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Rezyume kartalari
                          Expanded(
                            child: Obx(() {
                              // Trigger rebuild when selectedResumeId changes
                              selectedResumeId.value;
                              return ListView.separated(
                                shrinkWrap: true,
                                itemCount: funcController.resumes.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final resume = funcController.resumes[index];
                                  return _ResumeCard(
                                    title: resume.title ?? 'Noma’lum'.tr,
                                    content: resume.content,
                                    educationCount:
                                        resume.education?.length ?? 0,
                                    experienceCount:
                                        resume.experience?.length ?? 0,
                                    createdAt:
                                        resume.createdAt == null
                                            ? null
                                            : _formatDate(resume.createdAt!),
                                    isSelected:
                                        selectedResumeId.value == resume.id,
                                    onTap:
                                        () =>
                                            selectedResumeId.value = resume.id!,
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Xabar yozish
                  TextField(
                    key: messageFieldKey,
                    controller: messageController,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      // Scroll to the message field when tapped
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (!scrollController.hasClients) return;
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    onSubmitted: (_) {
                      // Prevent page refresh and resume reload when done button is pressed
                      // Use WidgetsBinding to ensure unfocus works properly
                      WidgetsBinding.instance.focusManager.primaryFocus
                          ?.unfocus();
                    },
                    // Chegara, toʼldirish va matn uslubi mavzudan keladi.
                    decoration: InputDecoration(
                      labelText: 'Xabar'.tr,
                      hintText: 'Murojaat matnini kiriting...'.tr,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Tugmalar
                  _DialogActions(
                    cancelLabel: 'Bekor qilish'.tr,
                    onCancel:
                        () => Navigator.of(context, rootNavigator: true).pop(),
                    confirmLabel: 'Yuborish'.tr,
                    confirmIcon: LucideIcons.send,
                    onConfirm: () async {
                      if (selectedResumeId.value == -1) {
                        ShowToast.show(
                          'Xatolik'.tr,
                          'Iltimos, rezyume tanlang'.tr,
                          1,
                          1,
                        );
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                      await apiController.createApplication(
                        postId,
                        messageController.text,
                        selectedResumeId.value,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Bugun'.tr;
      } else if (difference.inDays == 1) {
        return 'Kecha'.tr;
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${'kun oldin'.tr}';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks ${'hafta oldin'.tr}';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  String _maskPhoneNumber(String phone) {
    // Uzbek phone format: +998 XX XXX XX XX
    if (phone.startsWith('+998')) {
      return '+998 ** *** ** **';
    } else {
      // Fallback for other formats
      return phone.replaceAll(RegExp(r'\d'), '*');
    }
  }

  void _moveMap(LatLng point, double zoom) => mapController.animateTo(
    dest: point,
    zoom: zoom,
    duration: const Duration(milliseconds: 900),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        // Panel uslubi mavzudagi `appBarTheme` dan keladi.
        appBar: AppBar(
          title: Text('E’lon tafsilotlari'.tr),
          actions: [
            Obx(() {
              final isFavorite = funcController.wishList.any(
                (w) => w.id == widget.post.id,
              );
              return IconButton(
                icon: AnimatedScale(
                  // Saralanganga qoʻshilganda belgi yengil "urib" qoʻyadi.
                  scale: isFavorite ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavorite
                            ? AppColors.red
                            : AppColors.textSecondaryColor,
                    size: 22,
                  ),
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await apiController.removeFromWishlist(
                      widget.post.id!.toInt(),
                    );
                  } else {
                    await apiController.addToWishlist(widget.post.id!.toInt());
                  }
                },
              );
            }),
          ],
        ),
        body: AppContentWidth(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 200),
                  childAnimationBuilder:
                      (widget) => SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(child: widget),
                      ),
                  children: [
                    // 1. Surat
                    if (widget.post.pictureUrl != null &&
                        widget.post.pictureUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: Responsive.scaleHeight(200, context),
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl:
                                widget.post.pictureUrl!.startsWith('http')
                                    ? widget.post.pictureUrl!
                                    : 'https://ishtopchi.uz${widget.post.pictureUrl}',
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.iconColor,
                                    strokeWidth: 2,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  height: Responsive.scaleHeight(200, context),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      LucideIcons.imageOff,
                                      size: Responsive.scaleFont(48, context),
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // 2. Sarlavha
                    Text(
                      widget.post.title ?? 'Noma’lum'.tr,
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // 3. Ish turi va bandlik turi — yorliqlar sifatida
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.post.jobType != null)
                          _DetailChip(
                            icon: LucideIcons.briefcaseBusiness,
                            label: _jobTypeLabel(widget.post.jobType),
                          ),
                        if (widget.post.employmentType != null)
                          _DetailChip(
                            icon: LucideIcons.briefcase,
                            label: _employmentTypeLabel(
                              widget.post.employmentType,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // 4-5. Ish haqi, joylashuv va sana — bitta kartada
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusCard,
                        ),
                        border: Border.all(
                          color: AppColors.textColor.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ish haqi — eʼlonning eng muhim raqami.
                          Row(
                            children: [
                              Icon(
                                LucideIcons.wallet,
                                size: 17,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  '${widget.post.salaryFrom ?? 'Noma’lum'.tr} - ${widget.post.salaryTo ?? 'Noma’lum'.tr} UZS',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: AppColors.primaryColor),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            height: 20,
                            thickness: 1,
                            color: AppColors.textColor.withValues(alpha: 0.08),
                          ),
                          _DetailRow(
                            icon: LucideIcons.mapPin,
                            text:
                                widget.post.district?.name ??
                                widget.post.location?.title ??
                                'Noma’lum tuman'.tr,
                          ),
                          if (widget.post.createdAt != null) ...[
                            const SizedBox(height: 10),
                            _DetailRow(
                              icon: LucideIcons.calendar,
                              text:
                                  '${'Joylashtirilgan'.tr}: ${widget.post.createdAt!.substring(0, 10)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // 6. Tavsif
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusCard,
                        ),
                        border: Border.all(
                          color: AppColors.textColor.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.post.content ?? 'Tavsif yo‘q'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // 7. Bog‘lanish uchun
                    _SectionLabel(text: 'Bog‘lanish uchun'.tr),
                    if (widget.post.phoneNumber != null)
                      _ContactTile(
                        icon: LucideIcons.phone,
                        text:
                            funcController.globalToken.value.isNotEmpty
                                ? widget.post.phoneNumber!
                                : _maskPhoneNumber(widget.post.phoneNumber!),
                        onTap: () async {
                          if (funcController.globalToken.value.isNotEmpty) {
                            final url = Uri.parse(
                              'tel:${widget.post.phoneNumber}',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              Get.snackbar(
                                'Xato'.tr,
                                'Qo‘ng‘iroq qilib bo‘lmadi'.tr,
                              );
                            }
                          } else {
                            _showLoginPromptDialog(context);
                          }
                        },
                      ),
                    if (widget.post.email != null)
                      _ContactTile(
                        icon: LucideIcons.mail,
                        text: widget.post.email!,
                        onTap: () async {
                          final url = Uri.parse('mailto:${widget.post.email}');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            Get.snackbar(
                              'Xato'.tr,
                              'Email yuborib bo‘lmadi'.tr,
                            );
                          }
                        },
                      ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    AnimationConfiguration.staggeredList(
                      position: 10, // Mos index
                      duration: const Duration(milliseconds: 200),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: AppButton(
                            label: 'Murojaat qilish'.tr,
                            leading: const Icon(LucideIcons.send),
                            filled: true,
                            onPressed: () {
                              if (funcController.globalToken.value.isNotEmpty) {
                                _showApplicationDialog(
                                  context,
                                  apiController,
                                  widget.post.id!,
                                );
                              } else {
                                _showLoginPromptDialog(context);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // 8. Foydalanuvchi ismi
                    _SectionLabel(text: 'E’lon egasi'.tr),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.035),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusControl,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 21,
                            backgroundImage:
                                widget.post.user?.profilePicture != null
                                    ? NetworkImage(
                                      funcController.getProfileUrl(
                                        widget.post.user!.profilePicture,
                                      ),
                                    )
                                    : null,
                            backgroundColor: colors.primary.withValues(
                              alpha: 0.12,
                            ),
                            child:
                                widget.post.user?.profilePicture == null
                                    ? Icon(
                                      LucideIcons.user,
                                      size: 19,
                                      color: colors.primary,
                                    )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}'
                                  .trim(),
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.paddingMedium),
                    // 9. Xarita - faqat ro'yxatdan o'tgan foydalanuvchilar uchun
                    Obx(
                      () =>
                          funcController.globalToken.value.isNotEmpty
                              ? Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard,
                                  ),
                                  border: Border.all(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    final location =
                                        controller.selectedLocation.value;
                                    if (location != null) {
                                      MapLauncherBottomSheet.show(
                                        context: context,
                                        coordinates: location,
                                        title:
                                            widget.post.district?.name ??
                                            widget.post.location?.title ??
                                            'Joylashuv',
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: Responsive.scaleHeight(
                                      300,
                                      context,
                                    ),
                                    child: FlutterMap(
                                      mapController:
                                          mapController.mapController,
                                      options: MapOptions(
                                        initialCenter:
                                            controller.selectedLocation.value ??
                                            LatLng(41.3111, 69.2401),
                                        initialZoom:
                                            controller.currentZoom.value,
                                        onMapReady: () {
                                          controller.isMapReady.value = true;
                                        },
                                        onTap: (tapPosition, point) {
                                          final location =
                                              controller.selectedLocation.value;
                                          if (location != null) {
                                            MapLauncherBottomSheet.show(
                                              context: context,
                                              coordinates: location,
                                              title:
                                                  widget.post.district?.name ??
                                                  widget.post.location?.title ??
                                                  'Joylashuv',
                                            );
                                          }
                                        },
                                        interactionOptions:
                                            const InteractionOptions(
                                              flags: InteractiveFlag.none,
                                            ),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: const ['a', 'b', 'c'],
                                          userAgentPackageName:
                                              'torex.top.ishtopchi',
                                        ),
                                        Obx(
                                          () => MarkerLayer(
                                            markers: [
                                              if (controller
                                                      .currentLocation
                                                      .value !=
                                                  null)
                                                Marker(
                                                  width: 38.0,
                                                  height: 38.0,
                                                  point:
                                                      controller
                                                          .currentLocation
                                                          .value!,
                                                  child: const AppMapPin(
                                                    accent: false,
                                                  ),
                                                ),
                                              Marker(
                                                width: 38.0,
                                                height: 38.0,
                                                point:
                                                    controller
                                                        .selectedLocation
                                                        .value ??
                                                    LatLng(41.3111, 69.2401),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final location =
                                                        controller
                                                            .selectedLocation
                                                            .value;
                                                    if (location != null) {
                                                      MapLauncherBottomSheet.show(
                                                        context: context,
                                                        coordinates: location,
                                                        title:
                                                            widget
                                                                .post
                                                                .district
                                                                ?.name ??
                                                            widget
                                                                .post
                                                                .location
                                                                ?.title ??
                                                            'Joylashuv',
                                                      );
                                                    }
                                                  },
                                                  child: const AppMapPin(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    SizedBox(height: AppDimensions.paddingLarge),
                    // 10. ID, Ko‘rishlar, Shikoyat
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.onSurface.withValues(alpha: 0.07),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _MetaItem(
                          icon: LucideIcons.hash,
                          text: '${widget.post.id ?? 'Noma’lum'.tr}',
                        ),
                        const SizedBox(width: 18),
                        _MetaItem(
                          icon: LucideIcons.eye,
                          text: '${widget.post.views ?? 0} ${'ko‘rish'.tr}',
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed:
                              () => _showComplaintDialog(
                                context,
                                apiController,
                                widget.post.id!,
                              ),
                          icon: const Icon(LucideIcons.circleAlert, size: 15),
                          label: Text('Shikoyat qilish'.tr),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 34),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.paddingLarge),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barcha oynalar uchun yagona qobiq: mavzudagi yuza, radius va
/// ochilishdagi yumshoq kattalashish.
class _DialogShell extends StatelessWidget {
  const _DialogShell({required this.child, this.maxHeightFactor});

  final Widget child;
  final double? maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final reduceMotion = media.disableAnimations;

    Widget content = Container(
      decoration: BoxDecoration(
        // Sahifa emas, undan bir pogʻona tepadagi yuza: qora fonda oyna
        // fondan ajralib turishi kerak.
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusSheet),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );

    if (maxHeightFactor != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: media.size.height * maxHeightFactor!,
        ),
        child: content,
      );
    }

    final dialog = Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: content,
    );

    if (reduceMotion) return dialog;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder:
          (context, value, child) => Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.965 + (0.035 * value),
              child: child,
            ),
          ),
      child: dialog,
    );
  }
}

/// Murojaat oynasidagi tanlanadigan rezyume kartasi.
class _ResumeCard extends StatelessWidget {
  const _ResumeCard({
    required this.title,
    required this.content,
    required this.educationCount,
    required this.experienceCount,
    required this.createdAt,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String? content;
  final int educationCount;
  final int experienceCount;
  final String? createdAt;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.55);
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color:
            isSelected
                ? colors.primary.withValues(alpha: 0.08)
                : colors.onSurface.withValues(alpha: 0.035),
        borderRadius: radius,
        border: Border.all(
          color:
              isSelected
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.08),
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: colors.primary.withValues(alpha: 0.06),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sarlavha va tanlov belgisi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tanlanganda belgi yumshoq kattalashadi.
                    AnimatedScale(
                      scale: isSelected ? 1.0 : 0.92,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 21,
                        height: 21,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSelected ? colors.primary : Colors.transparent,
                          border:
                              isSelected
                                  ? null
                                  : Border.all(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.28,
                                    ),
                                    width: 1.6,
                                  ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  LucideIcons.check,
                                  color: colors.onPrimary,
                                  size: 13,
                                )
                                : null,
                      ),
                    ),
                  ],
                ),
                if (content != null && content!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      content!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: muted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // Qisqacha raqamlar
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      if (educationCount > 0) ...[
                        Icon(LucideIcons.graduationCap, size: 12, color: muted),
                        const SizedBox(width: 5),
                        Text(
                          '$educationCount ${'Ta’lim'.tr}',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                      if (educationCount > 0 && experienceCount > 0)
                        const SizedBox(width: 14),
                      if (experienceCount > 0) ...[
                        Icon(LucideIcons.briefcase, size: 12, color: muted),
                        const SizedBox(width: 5),
                        Text(
                          '$experienceCount ${'tajriba'.tr}',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                      ],
                      const Spacer(),
                      if (createdAt != null)
                        Text(
                          createdAt!,
                          style: TextStyle(fontSize: 10.5, color: muted),
                        ),
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
}

/// Oyna pastidagi "bekor qilish / tasdiqlash" juftligi.
class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.cancelLabel,
    required this.onCancel,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmIcon,
  });

  final String cancelLabel;
  final VoidCallback onCancel;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final IconData? confirmIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: colors.onSurface.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            minimumSize: const Size(0, 46),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusControl),
            ),
          ),
          child: Text(cancelLabel),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AppButton(
            label: confirmLabel,
            leading: confirmIcon == null ? null : Icon(confirmIcon),
            filled: true,
            onPressed: onConfirm,
          ),
        ),
      ],
    );
  }
}

/// Bo'lim sarlavhasi — tanadagi barcha guruhlar uchun bir xil.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          letterSpacing: 0.9,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Telefon / email kabi bosiladigan bog'lanish qatori.
class _ContactTile extends StatefulWidget {
  const _ContactTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusControl);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Material(
          color: colors.onSurface.withValues(alpha: 0.035),
          borderRadius: radius,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: radius,
            splashColor: colors.primary.withValues(alpha: 0.07),
            highlightColor: colors.primary.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(widget.icon, size: 17, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: colors.onSurface.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pastki qatordagi kichik ma'lumot (ID, ko'rishlar).
class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: muted),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12.5,
            color: muted,
          ),
        ),
      ],
    );
  }
}

/// Eʼlon turini bildiruvchi yorliq.
class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tafsilotlar kartasidagi bitta qator.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Icon(icon, size: 15, color: muted),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: muted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Ish turi nomi.
String _jobTypeLabel(String? type) {
  switch (type) {
    case 'FULL_TIME':
      return 'To‘liq ish kuni'.tr;
    case 'TEMPORARY':
      return 'Vaqtinchalik ish'.tr;
    case 'REMOTE':
      return 'Masofaviy ish'.tr;
    case 'DAILY':
      return 'Kunlik ish'.tr;
    case 'PROJECT_BASED':
      return 'Loyihaviy ish'.tr;
    case 'INTERNSHIP':
      return 'Amaliyot'.tr;
    default:
      return 'Noma’lum'.tr;
  }
}

/// Bandlik turi nomi.
String _employmentTypeLabel(String? type) {
  switch (type) {
    case 'FULL_TIME':
      return 'To‘liq ish kuni'.tr;
    case 'PART_TIME':
      return 'Yarim stavka'.tr;
    case 'SHIFT_BASED':
      return 'Smenali ish'.tr;
    case 'FLEXIBLE':
      return 'Moslashuvchan ish'.tr;
    case 'REGULAR_SCHEDULE':
      return 'Doimiy jadval'.tr;
    default:
      return 'Noma’lum'.tr;
  }
}
