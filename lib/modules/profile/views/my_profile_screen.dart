import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/user_me.dart';
import '../../../core/utils/responsive.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
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
    return url.startsWith('http') ? url : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = funcController.userMe.value;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            pinned: true,
            expandedHeight: Responsive.scaleHeight(300, context),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: Responsive.scaleFont(25, context)),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, user),
            ),
            actions: [

              TextButton.icon(
                onPressed: () => Get.to(() => EditProfileScreen()),
                icon: Icon(LucideIcons.userRoundPen, color: Colors.white, size: Responsive.scaleFont(20, context)),
                label: Text(
                  'Tahrirlash',
                  style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(17, context)),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleWidth(12, context),
                    vertical: Responsive.scaleHeight(8, context),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scaleWidth(16, context),
                vertical: Responsive.scaleHeight(24, context),
              ),
              child: _buildBody(context, user),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserMe? user) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkBlue,AppColors.darkNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: Responsive.scaleHeight(75, context)),
          Text(
            'ID: ${user?.data?.id.toString() ?? 'Kiritilmagan'}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.scaleFont(16, context),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.scaleHeight(12, context)),
          GestureDetector(
            onTap: () {
              if (user?.data?.profilePicture != null) {
                Get.to(FullScreenImage(url: _getProfileUrl(user!.data!.profilePicture)));
              }
            },
            child: Hero(
              tag: 'profile-image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(150),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightBlue, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: _getProfileUrl(user?.data?.profilePicture),
                    height: Responsive.scaleHeight(140, context),
                    width: Responsive.scaleWidth(140, context),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.lightBlue,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.darkBlue,
                      child: Icon(
                        LucideIcons.imageOff,
                        size: Responsive.scaleFont(40, context),
                        color: AppColors.lightGray,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.scaleHeight(16, context)),
          Text(
            user?.data?.firstName != null
                ? '${user!.data!.firstName} ${user.data!.lastName ?? ''}'
                : user?.data?.lastName ?? 'Ism yo‘q',
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.scaleFont(22, context),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: Responsive.scaleHeight(8, context)),
          Text(
            user?.data?.authProviders?.isNotEmpty ?? false
                ? user!.data!.authProviders!.first.email ?? user.data!.authProviders!.first.providersUserId ?? 'Ma’lumot yo‘q'
                : 'Ma’lumot yo‘q',
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.scaleFont(14, context),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserMe? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Statistika'),
        SizedBox(height: Responsive.scaleHeight(12, context)),
        Obx(() {
          if (funcController.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
          }
          if (funcController.meStats.value.data == null) {
            return Text(
              'Ma’lumotlar mavjud emas',
              style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(14, context)),
            );
          }
          return Wrap(
            spacing: Responsive.scaleWidth(16, context),
            runSpacing: Responsive.scaleHeight(12, context),
            children: [
              _buildStatCard(
                context,
                icon: LucideIcons.squareLibrary,
                title: 'Postlar',
                value: funcController.meStats.value.data?.postcount ?? '0',
              ),
              _buildStatCard(
                context,
                icon: LucideIcons.eye,
                title: 'Ko‘rishlar',
                value: funcController.meStats.value.data?.totalViews ?? '0',
              ),
              _buildStatCard(
                context,
                icon: LucideIcons.fileText,
                title: 'Resumelar',
                value: (user?.data?.resumes?.length ?? 0).toString(),
              ),
            ],
          );
        }),
        SizedBox(height: Responsive.scaleHeight(24, context)),
        _buildSectionTitle(context, 'Shaxsiy ma’lumotlar'),
        SizedBox(height: Responsive.scaleHeight(12, context)),
        Column(
          children: [
            _buildInfoCard(
              context,
              icon: LucideIcons.mapPin,
              title: 'Manzil',
              value: user?.data?.district != null
                  ? '${user!.data!.district!.name}, ${user.data!.district!.region!.name}'
                  : 'Manzil kiritilmagan',
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoCard(
              context,
              icon: LucideIcons.user,
              title: 'Jins',
              value: user?.data?.gender == 'MALE' ? 'Erkak' : user?.data?.gender == 'FEMALE' ? 'Ayol' : 'Kiritilmagan',
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoCard(
              context,
              icon: LucideIcons.calendar,
              title: 'Tug‘ilgan sana',
              value: user?.data?.birthDate ?? 'Kiritilmagan',
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoCard(
              context,
              icon: LucideIcons.check,
              title: 'Tasdiqlangan',
              value: user?.data?.verified == true ? 'Ha' : 'Yo‘q',
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoCard(
              context,
              icon: LucideIcons.userCheck,
              title: 'Rol',
              value: user?.data?.role ?? 'Kiritilmagan',
            ),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoCard(
              context,
              icon: LucideIcons.clock,
              title: 'Ro‘yxatdan o‘tgan sana',
              value: user?.data?.createdAt != null
                  ? user!.data!.createdAt!.split('T')[0]
                  : 'Kiritilmagan',
            ),
          ],
        ),
        SizedBox(height: Responsive.scaleHeight(24, context)),
        _buildSectionTitle(context, 'Hisobni boshqarish'),
        SizedBox(height: Responsive.scaleHeight(12, context)),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _deleteAccount,
            icon: Icon(LucideIcons.trash2, color: Colors.white, size: Responsive.scaleFont(18, context)),
            label: Text(
              'Hisobni o‘chirish',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.scaleFont(16, context),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(
                vertical: Responsive.scaleHeight(12, context),
                horizontal: Responsive.scaleWidth(20, context),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: Colors.black45,
            ),
          ),
        ),
        SizedBox(height: Responsive.scaleHeight(24, context)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: Responsive.scaleWidth(8, context)),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade300,
          fontWeight: FontWeight.w600,
          fontSize: Responsive.scaleFont(18, context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.darkBlue,
        title: Text(
          'Hisobni o‘chirish',
          style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(18, context)),
        ),
        content: Text(
          'Hisobingizni o‘chirishni xohlaysizmi? Bu amal qaytarib bo‘lmaydi.',
          style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(14, context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: AppColors.lightBlue, fontSize: Responsive.scaleFont(14, context)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'O‘chirish',
              style: TextStyle(color: Colors.redAccent, fontSize: Responsive.scaleFont(14, context)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // await apiController.deleteAccount(); // Hisobni o‘chirish funksiyasi
    }
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: Responsive.scaleWidth(120, context),
      padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue.withOpacity(0.7), AppColors.darkBlue.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.lightBlue,
            size: Responsive.scaleFont(28, context),
          ),
          SizedBox(height: Responsive.scaleHeight(8, context)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: Responsive.scaleFont(22, context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: Responsive.scaleHeight(4, context)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.scaleFont(14, context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
      }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        vertical: Responsive.scaleHeight(10, context),
        horizontal: Responsive.scaleWidth(14, context),
      ),
      margin: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(4, context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue.withOpacity(0.5), AppColors.darkBlue.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.lightBlue,
            size: Responsive.scaleFont(18, context),
          ),
          SizedBox(width: Responsive.scaleWidth(12, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: Responsive.scaleFont(13, context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(2, context)),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: Responsive.scaleFont(15, context),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String url;

  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Get.back(),
        child: Center(
          child: Hero(
            tag: 'profile-image',
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => CircularProgressIndicator(color: AppColors.lightBlue),
              errorWidget: (context, url, error) => Icon(LucideIcons.imageOff, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}