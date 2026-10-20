import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../common/widgets/post_card.dart';
import '../../../common/widgets/refresh_component.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../main/views/skeleton_post_card.dart';

/// Foydalanuvchining oʻz eʼlonlari.
class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  MyPostsScreenState createState() => MyPostsScreenState();
}

class MyPostsScreenState extends State<MyPostsScreen> {
  final FuncController funcController = Get.put(FuncController());
  final ApiController apiController = Get.find<ApiController>();
  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMyPosts();
    });
  }

  @override
  void dispose() {
    // Avval bu kontrollerlar hech qachon boʻshatilmasdi.
    refreshController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // E‘lonlarni yuklash
  Future<void> _loadMyPosts() async {
    try {
      funcController.isLoading.value = true;
      await apiController.fetchMyPosts(
        page: funcController.currentPage.value,
        search: funcController.searchQuery.value,
      );
    } catch (e) {
      debugPrint('Xatolik: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowToast.show('Xatolik'.tr, e.toString(), 3, 1);
      });
    } finally {
      funcController.isLoading.value = false;
    }
  }

  // E‘lonlarni yangilash
  void _onRefresh() async {
    funcController.currentPage.value = 1;
    funcController.hasMore.value = true;
    funcController.mePosts.clear();
    await _loadMyPosts();
    refreshController.refreshCompleted();
  }

  // Qo‘shimcha e‘lonlarni yuklash
  void _onLoading() async {
    if (funcController.hasMore.value && !funcController.isLoading.value) {
      funcController.currentPage.value++;
      await _loadMyPosts();
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Mening e’lonlarim'.tr,
      child: Column(
        children: [
          // Qidiruv maydoni
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: _buildSearchField(),
          ),
          // Joylashuv, soni va ko‘rinish tugmalari
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _buildToolbar(),
          ),
          // E‘lonlar ro‘yxati
          Expanded(
            child: RefreshComponent(
              refreshController: refreshController,
              scrollController: scrollController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              enablePullUp: funcController.hasMore.value,
              // Slayverlar toʻgʻridan-toʻgʻri `SmartRefresher` ga beriladi
              // (asosiy lentadagi bilan bir xil sabab): aks holda roʻyxat
              // bir slayver ichida cheksiz balandlik olib, `shrinkWrap`
              // bilan barcha kartalarni birdan qurardi.
              child: CustomScrollView(
                slivers: [
                  Obx(() {
                    final posts = funcController.mePosts;
                    final isLoading = funcController.isLoading.value;

                    if (isLoading && posts.isEmpty) {
                      return _buildList(
                        context,
                        itemCount: 6,
                        builder: (context, index) => const SkeletonPostCard(),
                      );
                    }

                    if (posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: AppEmptyState(
                          icon: LucideIcons.fileX,
                          title: 'Hozircha e’lonlaringiz yo‘q'.tr,
                          message:
                              'Yangi e’lon qo‘shish uchun quyidagi tugmani bosing'
                                  .tr,
                          actionLabel: 'E’lon qo‘shish'.tr,
                          actionIcon: const Icon(LucideIcons.circlePlus),
                          onAction: () {
                            Navigator.of(context).pop();
                            funcController.setBarIndex(1);
                          },
                        ),
                      );
                    }

                    return _buildList(
                      context,
                      itemCount: posts.length,
                      builder: (context, index) {
                        final post = posts[index];
                        return AppReveal(
                          delay: AppReveal.step(index),
                          child: PostCard(post: post, mePost: true),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Qidirish...'.tr,
        prefixIcon: Icon(
          LucideIcons.search,
          size: 19,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
      ),
      onChanged: (value) async {
        funcController.searchQuery.value = value;
        funcController.currentPage.value = 1;
        funcController.hasMore.value = true;
        funcController.mePosts.clear();
        await _loadMyPosts();
        refreshController.refreshCompleted();
      },
    );
  }

  Widget _buildToolbar() {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Obx(
          () => _Chip(
            icon: LucideIcons.mapPin,
            label:
                funcController.userMe.value.data?.district?.name ??
                'Viloyat'.tr,
          ),
        ),
        Expanded(
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.megaphone, size: 16, color: muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${funcController.totalMePosts} ${'ta e’lon'.tr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(
          () => _Chip(
            icon:
                !funcController.isGridView.value
                    ? LucideIcons.grid2x2
                    : LucideIcons.list,
            onTap:
                () =>
                    funcController.isGridView.value =
                        !funcController.isGridView.value,
          ),
        ),
      ],
    );
  }

  /// Roʻyxat yoki katak — slayver koʻrinishida.
  Widget _buildList(
    BuildContext context, {
    required int itemCount,
    required Widget Function(BuildContext, int) builder,
  }) {
    // Yuklash paneli oʻchirilgan boʻlsa, oxirgi karta suzuvchi pastki
    // panel ostida qolmasligi uchun uning balandligicha boʻshliq.
    final bottomInset =
        funcController.hasMore.value
            ? 0.0
            : MediaQuery.paddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(8, 0, 8, 16 + bottomInset);

    final sliver =
        funcController.isGridView.value
            ? SliverGrid(
              gridDelegate: PostCard.gridDelegate(context, mePost: true),
              delegate: SliverChildBuilderDelegate(
                builder,
                childCount: itemCount,
              ),
            )
            : SliverList(
              delegate: SliverChildBuilderDelegate(
                builder,
                childCount: itemCount,
              ),
            );

    return SliverPadding(padding: padding, sliver: sliver);
  }
}

/// Panel ustidagi kichik tugma.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, this.label, this.onTap});

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.65);
    final radius = BorderRadius.circular(12);

    return Material(
      color: theme.cardTheme.color ?? colors.surfaceContainer,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: colors.onSurface.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: muted),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
