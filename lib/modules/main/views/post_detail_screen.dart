import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailScreen extends StatefulWidget {
  final Data post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> with TickerProviderStateMixin {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  late final PostDetailController controller;
  late final AnimatedMapController mapController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostDetailController());
    mapController = AnimatedMapController(vsync: this);
    final latitude = widget.post.location?.latitude is String
        ? double.tryParse(widget.post.location!.latitude!)
        : widget.post.location?.latitude as double?;
    final longitude = widget.post.location?.longitude is String
        ? double.tryParse(widget.post.location!.longitude!)
        : widget.post.location?.longitude as double?;
    if (latitude != null && longitude != null) {
      controller.setInitialLocation(LatLng(latitude, longitude));
    }
    print(jsonEncode(widget.post));
    print('Picture URL: ${widget.post.pictureUrl}');
  }

  @override
  void dispose() {
    mapController.dispose();
    Get.delete<PostDetailController>();
    super.dispose();
  }

  void _moveMap(LatLng point, double zoom) => mapController.animateTo(
    dest: point,
    zoom: zoom,
    duration: const Duration(milliseconds: 900),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            color: AppColors.white,
            size: Responsive.scaleFont(22, context),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'E‘lon tafsilotlari',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.white,
            fontSize: Responsive.scaleFont(18, context),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final isFavorite = funcController.wishList.any((w) => w.id == widget.post.id);
            return IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.red : AppColors.lightGray.withOpacity(0.7),
                size: Responsive.scaleFont(22, context),
              ),
              onPressed: () async {
                if (isFavorite) {
                  await apiController.removeFromWishlist(widget.post.id!.toInt());
                } else {
                  await apiController.addToWishlist(widget.post.id!.toInt());
                }
              },
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 300),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // 1. Surat
                if (widget.post.pictureUrl != null && widget.post.pictureUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: Responsive.scaleHeight(200, context),
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: widget.post.pictureUrl!.startsWith('http')
                            ? widget.post.pictureUrl!
                            : 'https://ishtopchi.uz${widget.post.pictureUrl}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.lightBlue.withOpacity(0.7),
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: Responsive.scaleHeight(200, context),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.darkBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.imageOff,
                              size: Responsive.scaleFont(48, context),
                              color: AppColors.lightGray.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 2. Sarlavha
                Text(
                  widget.post.title ?? 'Noma’lum',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Responsive.scaleFont(22, context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 3. Joylashtirilgan vaqt
                if (widget.post.createdAt != null)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: Responsive.scaleFont(16, context),
                        color: AppColors.lightGray.withOpacity(0.7),
                      ),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Text(
                        'Joylashtirilgan: ${widget.post.createdAt!.substring(0, 10)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: Responsive.scaleFont(13, context),
                          color: AppColors.lightGray.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 4. Ish haqi
                Row(
                  children: [
                    Icon(
                      LucideIcons.wallet,
                      size: Responsive.scaleFont(16, context),
                      color: AppColors.lightBlue.withOpacity(0.8),
                    ),
                    SizedBox(width: Responsive.scaleWidth(6, context)),
                    Text(
                      '${widget.post.salaryFrom ?? 'Noma’lum'} - ${widget.post.salaryTo ?? 'Noma’lum'} UZS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: Responsive.scaleFont(14, context),
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 5. Joylashuv
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: Responsive.scaleFont(16, context),
                      color: AppColors.lightBlue.withOpacity(0.8),
                    ),
                    SizedBox(width: Responsive.scaleWidth(6, context)),
                    Expanded(
                      child: Text(
                        widget.post.district?.name ?? widget.post.location?.title ?? 'Noma’lum tuman',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: Responsive.scaleFont(14, context),
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 6. Tavsif
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.post.content ?? 'Tavsif yo‘q',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: Responsive.scaleFont(15, context),
                      color: AppColors.lightGray.withOpacity(0.9),
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 7. Bog‘lanish uchun
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bog‘lanish uchun',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: Responsive.scaleFont(15, context),
                          color: AppColors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppDimensions.paddingSmall),
                      if (widget.post.phoneNumber != null)
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse('tel:${widget.post.phoneNumber}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              Get.snackbar('Xato', 'Qo‘ng‘iroq qilib bo‘lmadi');
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.phone,
                                size: Responsive.scaleFont(16, context),
                                color: AppColors.lightBlue.withOpacity(0.8),
                              ),
                              SizedBox(width: Responsive.scaleWidth(6, context)),
                              Text(
                                widget.post.phoneNumber!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: Responsive.scaleFont(13, context),
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.lightBlue.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.post.email != null) ...[
                        SizedBox(height: AppDimensions.paddingSmall),
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse('mailto:${widget.post.email}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              Get.snackbar('Xato', 'Email yuborib bo‘lmadi');
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.mail,
                                size: Responsive.scaleFont(16, context),
                                color: AppColors.lightBlue.withOpacity(0.8),
                              ),
                              SizedBox(width: Responsive.scaleWidth(6, context)),
                              Text(
                                widget.post.email!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: Responsive.scaleFont(13, context),
                                  color: AppColors.white,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.lightBlue.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 8. Foydalanuvchi ismi
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: Responsive.scaleWidth(20, context),
                        backgroundImage: widget.post.user?.profilePicture != null
                            ? NetworkImage(funcController.getProfileUrl(widget.post.user!.profilePicture))
                            : null,
                        backgroundColor: AppColors.darkBlue.withOpacity(0.15),
                        child: widget.post.user?.profilePicture == null
                            ? Icon(
                          LucideIcons.user,
                          size: Responsive.scaleFont(20, context),
                          color: AppColors.lightGray.withOpacity(0.7),
                        )
                            : null,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Expanded(
                        child: Text(
                          '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}'.trim(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: Responsive.scaleFont(15, context),
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 9. Xarita
                Obx(() => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: Responsive.scaleHeight(300, context),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController.mapController,
                          options: MapOptions(
                            initialCenter: controller.selectedLocation.value ?? LatLng(41.3111, 69.2401),
                            initialZoom: controller.currentZoom.value,
                            minZoom: 10.0,
                            maxZoom: 18.0,
                            onMapReady: () {
                              controller.isMapReady.value = true;
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'torex.top.ishtopchi',
                              tileSize: 256,
                              maxNativeZoom: 19,
                            ),
                            Obx(() => MarkerLayer(
                              markers: [
                                if (controller.currentLocation.value != null)
                                  Marker(
                                    width: 38.0,
                                    height: 38.0,
                                    point: controller.currentLocation.value!,
                                    child: const Icon(
                                      LucideIcons.locateFixed,
                                      color: Colors.blue,
                                      size: 18.0,
                                    ),
                                  ),
                                Marker(
                                  width: 38.0,
                                  height: 38.0,
                                  point: controller.selectedLocation.value ?? LatLng(41.3111, 69.2401),
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 28.0,
                                  ),
                                ),
                              ],
                            )),
                          ],
                        ),
                        Positioned(
                          right: AppDimensions.paddingSmall,
                          top: AppDimensions.paddingSmall,
                          child: Column(
                            children: [
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: AppColors.darkBlue.withOpacity(0.8),
                                elevation: 0.5,
                                onPressed: () => controller.zoomIn(_moveMap),
                                child: Icon(
                                  LucideIcons.plus,
                                  color: AppColors.lightGray.withOpacity(0.7),
                                  size: Responsive.scaleFont(14, context),
                                ),
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              FloatingActionButton(
                                mini: true,
                                backgroundColor: AppColors.darkBlue.withOpacity(0.8),
                                elevation: 0.5,
                                onPressed: () => controller.zoomOut(_moveMap),
                                child: Icon(
                                  LucideIcons.minus,
                                  color: AppColors.lightGray.withOpacity(0.7),
                                  size: Responsive.scaleFont(14, context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: AppDimensions.paddingSmall,
                          bottom: AppDimensions.paddingSmall,
                          child: FloatingActionButton(
                            mini: true,
                            heroTag: 'post_detail_location_${widget.post.id}_${UniqueKey()}',
                            backgroundColor: AppColors.darkBlue.withOpacity(0.8),
                            elevation: 0.5,
                            onPressed: () => controller.getCurrentLocation(_moveMap),
                            tooltip: 'Joriy joylashuvni aniqlash',
                            child: Icon(
                              LucideIcons.locate,
                              color: AppColors.lightBlue.withOpacity(0.8),
                              size: Responsive.scaleFont(14, context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                SizedBox(height: AppDimensions.paddingLarge),
                // 10. ID, Ko‘rishlar, Shikoyat
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.hash,
                            size: Responsive.scaleFont(16, context),
                            color: AppColors.lightGray.withOpacity(0.7),
                          ),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text(
                            'ID: ${widget.post.id ?? 'Noma’lum'}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Responsive.scaleFont(13, context),
                              color: AppColors.lightGray.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: Responsive.scaleFont(16, context),
                            color: AppColors.lightGray.withOpacity(0.7),
                          ),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text(
                            '${widget.post.views ?? 0} ko‘rish',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: Responsive.scaleFont(13, context),
                              color: AppColors.lightGray.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.paddingSmall),
                      GestureDetector(
                        onTap: () async {
                          /*try {
                            await apiController.reportPost(widget.post.id!.toInt());
                            Get.snackbar('Muvaffaqiyat', 'Shikoyat yuborildi');
                          } catch (e) {
                            Get.snackbar('Xato', 'Shikoyat yuborib bo‘lmadi');
                          }*/
                        },
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.circleAlert,
                              size: Responsive.scaleFont(16, context),
                              color: AppColors.red.withOpacity(0.8),
                            ),
                            SizedBox(width: Responsive.scaleWidth(6, context)),
                            Text(
                              'Shikoyat qilish',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: Responsive.scaleFont(13, context),
                                color: AppColors.red.withOpacity(0.8),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.red.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.yellow;
      case 'APPROVED':
        return AppColors.green;
      case 'REJECTED':
        return AppColors.red;
      default:
        return AppColors.lightGray.withOpacity(0.7);
    }
  }
}