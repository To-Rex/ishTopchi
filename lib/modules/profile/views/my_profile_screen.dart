import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/user_me.dart';
import '../../../core/utils/responsive.dart';
import 'edit_profile_screen.dart';

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
    return url.startsWith('http') ? url : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  String _getAuthMethod(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        return 'Google orqali kirilgan';
      } else if (provider == 'PHONE_NUMBER') {
        return 'Telefon raqami orqali kirilgan';
      }
    }
    return 'Ma’lumot yo‘q';
  }

  IconData _getAuthIcon(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        return LucideIcons.chrome;
      } else if (provider == 'PHONE_NUMBER') {
        return LucideIcons.phone;
      }
    }
    return LucideIcons.info;
  }

  List<Color> _getAuthGradient(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        return [Colors.blue.shade800, Colors.blue.shade400];
      } else if (provider == 'PHONE_NUMBER') {
        return [Colors.green.shade800, Colors.green.shade400];
      }
    }
    return [AppColors.lightBlue, AppColors.darkBlue];
  }

  Color _getAuthShadowColor(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first.providerType;
      if (provider == 'GOOGLE') {
        return AppColors.darkNavy;
      } else if (provider == 'PHONE_NUMBER') {
        return AppColors.lightBlue;
      }
    }
    return Colors.black26;
  }

  String _getAuthInfo(UserMe? user) {
    if (user?.data?.authProviders?.isNotEmpty ?? false) {
      final provider = user!.data!.authProviders!.first;
      return provider.email ?? provider.providersUserId ?? 'Ma’lumot yo‘q';
    }
    return 'Ma’lumot yo‘q';
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
                  style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context)),
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
              child: AnimationLimiter(
                child: _buildBody(context, user),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserMe? user) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: AnimationLimiter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 20.0, child: FadeInAnimation(child: widget)),
            children: [
              SizedBox(height: Responsive.scaleHeight(70, context)),
              Text('ID: ${user?.data?.id.toString() ?? 'Kiritilmagan'}', style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(15, context), fontWeight: FontWeight.w500)),
              SizedBox(height: Responsive.scaleHeight(25, context)),
              GestureDetector(
                onTap: () {
                  if (user?.data?.profilePicture != null) {
                    Get.to(FullScreenImage(url: _getProfileUrl(user!.data!.profilePicture)));
                  }
                },
                child: Hero(
                  tag: 'profile-image',
                  child: Container(
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CachedNetworkImage(
                          imageUrl: _getProfileUrl(user?.data?.profilePicture),
                          height: Responsive.scaleHeight(130, context),
                          width: Responsive.scaleWidth(130, context),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
                          errorWidget: (context, url, error) => Container(color: AppColors.darkBlue, child: Icon(LucideIcons.imageOff, size: Responsive.scaleFont(35, context), color: AppColors.lightGray))
                        )
                      )
                    )
                  )
                )
              ),
              SizedBox(height: Responsive.scaleHeight(12, context)),
              Text(user?.data?.firstName != null ? '${user!.data!.firstName} ${user.data!.lastName ?? ''}' : user?.data?.lastName ?? 'Ism yo‘q', style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(22, context), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              Text(_getAuthInfo(user), style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(14, context), fontStyle: FontStyle.italic, fontWeight: FontWeight.w400))
            ]
          )
        )
      )
    );
  }

  Widget _buildBody(BuildContext context, UserMe? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AnimationConfiguration.toStaggeredList(
        duration: const Duration(milliseconds: 600),
        childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 20.0, curve: Curves.easeOutBack, child: FadeInAnimation(child: widget)),
        children: [
          _buildSectionTitle(context, 'Statistika'),
          SizedBox(height: Responsive.scaleHeight(12, context)),
          Obx(() {
            if (funcController.isLoading.value) {
              return Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
            }
            if (funcController.meStats.value.data == null) {
              return Center(child: Text('Ma’lumotlar mavjud emas', style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(13, context))));
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  context,
                  icon: LucideIcons.squareLibrary,
                  title: 'Postlar',
                  value: funcController.meStats.value.data?.postcount ?? '0'
                ),
                _buildStatCard(
                  context,
                  icon: LucideIcons.eye,
                  title: 'Ko‘rishlar',
                  value: funcController.meStats.value.data?.totalViews ?? '0'
                ),
                _buildStatCard(
                  context,
                  icon: LucideIcons.fileText,
                  title: 'Resumelar',
                  value: (user?.data?.resumes?.length ?? 0).toString()
                )
              ]
            );
          }),
          SizedBox(height: Responsive.scaleHeight(20, context)),
          _buildSectionTitle(context, 'Kirish ma’lumotlari'),
          SizedBox(height: Responsive.scaleHeight(10, context)),
          Center(
            child: GestureDetector(
              onTap: () {
                Get.dialog(
                  Dialog(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Kirish ma’lumotlari',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.scaleFont(18, context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(8, context)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getAuthIcon(user),
                                color: Colors.white,
                                size: Responsive.scaleFont(20, context),
                              ),
                              SizedBox(width: Responsive.scaleWidth(8, context)),
                              Text(
                                _getAuthMethod(user),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.scaleFont(16, context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.scaleHeight(8, context)),
                          Text(
                            _getAuthInfo(user),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Responsive.scaleFont(14, context),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(16, context)),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Yopish',
                              style: TextStyle(
                                color: AppColors.lightBlue,
                                fontSize: Responsive.scaleFont(14, context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()..scale(1.0),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(10, context), horizontal: Responsive.scaleWidth(14, context)),
                    margin: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(4, context)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _getAuthGradient(user), begin: Alignment.centerLeft, end: Alignment.centerRight),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: _getAuthShadowColor(user), blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3))]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(_getAuthIcon(user), color: Colors.white, size: Responsive.scaleFont(25, context))
                        ),
                        SizedBox(width: Responsive.scaleWidth(12, context)),
                        Text(_getAuthMethod(user), style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w800))
                      ]
                    )
                  )
                )
              )
            )
          ),
          SizedBox(height: Responsive.scaleHeight(20, context)),
          _buildSectionTitle(context, 'Shaxsiy ma’lumotlar'),
          SizedBox(height: Responsive.scaleHeight(10, context)),
          Column(
            children: [
              _buildInfoCard(
                context,
                icon: LucideIcons.mapPin,
                title: 'Manzil',
                value: user?.data?.district != null ? '${user!.data!.district!.name}, ${user.data!.district!.region!.name}' : 'Manzil kiritilmagan'
              ),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildInfoCard(
                context,
                icon: LucideIcons.user,
                title: 'Jins',
                value: user?.data?.gender == 'MALE' ? 'Erkak' : user?.data?.gender == 'FEMALE' ? 'Ayol' : 'Kiritilmagan'
              ),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildInfoCard(
                context,
                icon: LucideIcons.calendar,
                title: 'Tug‘ilgan sana',
                value: user?.data?.birthDate ?? 'Kiritilmagan'
              ),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildInfoCard(
                context,
                icon: LucideIcons.check,
                title: 'Tasdiqlangan',
                value: user?.data?.verified == true ? 'Ha' : 'Yo‘q'
              ),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildInfoCard(
                context,
                icon: LucideIcons.userCheck,
                title: 'Rol',
                value: user?.data?.role ?? 'Kiritilmagan'
              ),
              SizedBox(height: Responsive.scaleHeight(6, context)),
              _buildInfoCard(
                context,
                icon: LucideIcons.clock,
                title: 'Ro‘yxatdan o‘tgan sana',
                value: user?.data?.createdAt != null ? user!.data!.createdAt!.split('T')[0] : 'Kiritilmagan'
              )
            ]
          ),
          SizedBox(height: Responsive.scaleHeight(20, context)),
          _buildSectionTitle(context, 'Hisobni boshqarish'),
          SizedBox(height: Responsive.scaleHeight(10, context)),
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.redAccent, Colors.red], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _deleteAccount,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context), horizontal: Responsive.scaleWidth(20, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.trash2, color: Colors.white, size: Responsive.scaleFont(16, context)),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text('Hisobni o‘chirish', style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(15, context), fontWeight: FontWeight.w600))
                      ]
                    )
                  )
                )
              )
            )
          ),
          SizedBox(height: Responsive.scaleHeight(150, context))
        ]
      )
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: Responsive.scaleWidth(6, context)),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade300,
          fontWeight: FontWeight.w600,
          fontSize: Responsive.scaleFont(17, context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.darkBlue, AppColors.darkNavy],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: ModalRoute.of(context)!.animation!,
                curve: Curves.easeOutBack,
              ),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: ModalRoute.of(context)!.animation!,
                  curve: Curves.easeOut,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hisobni o‘chirish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.scaleFont(18, context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(12, context)),
                    Text(
                      'Hisobingizni o‘chirishni xohlaysizmi? Bu amal qaytarib bo‘lmaydi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Responsive.scaleFont(14, context),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: Responsive.scaleHeight(20, context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text(
                            'Bekor qilish',
                            style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: Responsive.scaleFont(14, context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.redAccent, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Get.back(result: true),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.scaleHeight(10, context),
                                  horizontal: Responsive.scaleWidth(16, context),
                                ),
                                child: Text(
                                  'O‘chirish',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.scaleFont(14, context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
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
    if (confirm == true) {
      // await apiController.deleteAccount(); // Hisobni o‘chirish funksiyasi
    }
  }

  Widget _buildStatCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: Responsive.scaleWidth(100, context),
      padding: EdgeInsets.all(Responsive.scaleWidth(10, context)),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.darkNavy, blurRadius: 6, offset: Offset(0, 2))]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(icon, color: AppColors.lightBlue, size: Responsive.scaleFont(24, context))
          ),
          SizedBox(height: Responsive.scaleHeight(6, context)),
          Text(value, style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.bold)),
          SizedBox(height: Responsive.scaleHeight(4, context)),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: Responsive.scaleFont(12, context), fontWeight: FontWeight.w500))
        ]
      )
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(10, context), horizontal: Responsive.scaleWidth(14, context)),
      margin: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(4, context)),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withAlpha(100),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              color: AppColors.lightBlue,
              size: Responsive.scaleFont(25, context),
            ),
          ),
          SizedBox(width: Responsive.scaleWidth(20, context)),
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
                SizedBox(height: Responsive.scaleHeight(3, context)),
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