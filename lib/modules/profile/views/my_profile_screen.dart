import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/user_me.dart';
import 'edit_profile_screen.dart';

/// Foydalanuvchining oʻz profili: statistika va maʼlumotlar.
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  final ApiController apiController = Get.find<ApiController>();
  final FuncController funcController = Get.find<FuncController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiController.fetchUserStats();
    });
  }

  String _getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    if (url == null || url.trim().isEmpty) {
      return 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    }
    url = url.trim();
    return url.startsWith('http')
        ? url
        : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  String _getAuthMethod(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        return 'Google orqali kirilgan'.tr;
      } else if (provider == 'PHONE_NUMBER') {
        return 'Telefon raqami orqali kirilgan'.tr;
      }
    }
    return 'Ma’lumot yo‘q'.tr;
  }

  IconData _getAuthIcon(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        // Lucide brend belgilarini olib tashlagan (`LucideIcons.chrome`
        // yoʻq). FontAwesome'dagi haqiqiy Google belgisi ishlatiladi;
        // `.data` — uning ichidagi oddiy [IconData].
        return FontAwesomeIcons.google.data;
      } else if (provider == 'PHONE_NUMBER') {
        return LucideIcons.phone;
      }
    }
    return LucideIcons.info;
  }

  String _getAuthInfo(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first;
      return provider.email ?? provider.providersUserId ?? 'Ma’lumot yo‘q'.tr;
    }
    return 'Ma’lumot yo‘q'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = funcController.userMe.value;

      return AppScreen(
        title: 'Mening Profilim'.tr,
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const EditProfileScreen()),
            icon: const Icon(LucideIcons.pencil, size: 16),
            label: Text('Tahrirlash'.tr),
          ),
          const SizedBox(width: 6),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            AppReveal(child: _buildHeader(user)),
            const SizedBox(height: 22),
            AppSectionLabel(text: 'Statistika'.tr),
            AppReveal(delay: AppReveal.step(1), child: _buildStats(user)),
            const SizedBox(height: 14),
            AppSectionLabel(text: 'Kirish ma’lumotlari'.tr),
            AppReveal(
              delay: AppReveal.step(2),
              child: AppTile(
                icon: _getAuthIcon(user),
                title: _getAuthMethod(user),
                subtitle: _getAuthInfo(user),
                onTap: () => _showAuthDialog(user),
              ),
            ),
            const SizedBox(height: 10),
            AppSectionLabel(text: 'Shaxsiy ma’lumotlar'.tr),
            ..._buildPersonalInfo(user),
            const SizedBox(height: 10),
            AppSectionLabel(text: 'Hisobni boshqarish'.tr),
            AppReveal(
              delay: AppReveal.step(10),
              child: AppTile(
                icon: LucideIcons.trash2,
                title: 'Hisobni o‘chirish'.tr,
                danger: true,
                onTap: _deleteAccount,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Surat, ism va kirish usuli.
  Widget _buildHeader(UserMe? user) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageUrl = _getProfileUrl(user?.data?.profilePicture);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Get.to(FullScreenImage(url: imageUrl)),
            child: Hero(
              tag: 'profile-image',
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget:
                      (context, _, _) => Icon(
                        LucideIcons.user,
                        size: 36,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.data?.firstName != null
                ? '${user!.data!.firstName} ${user.data!.lastName ?? ''}'
                : user?.data?.lastName ?? 'Ism yo‘q'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Text(
            _getAuthInfo(user),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${'ID'.tr}: ${user?.data?.id.toString() ?? 'Kiritilmagan'.tr}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Uchta koʻrsatkich.
  Widget _buildStats(UserMe? user) {
    return Obx(() {
      if (funcController.meStats.value.data == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Ma’lumotlar mavjud emas'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: LucideIcons.squareLibrary,
              title: 'Postlar'.tr,
              value: funcController.meStats.value.data?.postcount ?? '0',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.eye,
              title: 'Ko‘rishlar'.tr,
              value: funcController.meStats.value.data?.totalViews ?? '0',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: LucideIcons.fileText,
              title: 'Rezyumelar'.tr,
              value: (user?.data?.resumes?.length ?? 0).toString(),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildPersonalInfo(UserMe? user) {
    final items = <({IconData icon, String title, String value})>[
      (
        icon: LucideIcons.mapPin,
        title: 'Manzil'.tr,
        value:
            user?.data?.district != null
                ? '${user!.data!.district!.name}, ${user.data!.district!.region!.name}'
                : 'Manzil kiritilmagan',
      ),
      (
        icon: LucideIcons.user,
        title: 'Jins'.tr,
        value:
            user?.data?.gender == 'MALE'
                ? 'Erkak'.tr
                : user?.data?.gender == 'FEMALE'
                ? 'Ayol'.tr
                : 'Kiritilmagan'.tr,
      ),
      (
        icon: LucideIcons.calendar,
        title: 'Tug‘ilgan sana'.tr,
        value: user?.data?.birthDate ?? 'Kiritilmagan'.tr,
      ),
      (
        icon: LucideIcons.check,
        title: 'Tasdiqlangan'.tr,
        value: user?.data?.verified == true ? 'Ha'.tr : 'Yo‘q'.tr,
      ),
      (
        icon: LucideIcons.userCheck,
        title: 'Rol'.tr,
        value: user?.data?.role ?? 'Kiritilmagan'.tr,
      ),
      (
        icon: LucideIcons.clock,
        title: 'Ro‘yxatdan o‘tgan sana'.tr,
        value:
            user?.data?.createdAt != null
                ? user!.data!.createdAt!.split('T')[0]
                : 'Kiritilmagan'.tr,
      ),
    ];

    return [
      for (var i = 0; i < items.length; i++)
        AppReveal(
          delay: AppReveal.step(i + 3),
          child: AppTile(
            icon: items[i].icon,
            title: items[i].title,
            subtitle: items[i].value,
          ),
        ),
    ];
  }

  void _showAuthDialog(UserMe? user) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kirish ma’lumotlari'.tr, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _getAuthIcon(user),
                    size: 19,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getAuthMethod(user),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getAuthInfo(user),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Yopish'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final theme = Theme.of(context);

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(LucideIcons.triangleAlert, color: AppColors.red, size: 21),
            const SizedBox(width: 10),
            Text('Hisobni o‘chirish'.tr, style: theme.textTheme.titleLarge),
          ],
        ),
        content: Text(
          'Rostdan ham hisobingizni o‘chirmoqchimisiz?'.tr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Bekor qilish'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusControl),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // await apiController.deleteAccount(); // Hisobni o'chirish funksiyasi
    }
  }
}

/// Bitta koʻrsatkich katakchasi.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 19, color: colors.primary),
          const SizedBox(height: 9),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 19),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profil suratini butun ekranda koʻrsatish.
class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: 'profile-image',
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder:
                  (context, url) =>
                      const CircularProgressIndicator(color: Colors.white54),
              errorWidget:
                  (context, url, error) => const Icon(
                    LucideIcons.imageOff,
                    color: Colors.white,
                    size: 48,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
