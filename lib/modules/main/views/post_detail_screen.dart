import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../ad_posting/controllers/ad_posting_controller.dart';
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
    // Debug uchun post ma'lumotlarini chop etish
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
            size: Responsive.scaleFont(24, context),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'E‘lon tafsilotlari',
          style: TextStyle(
            color: AppColors.white,
            fontSize: Responsive.scaleFont(20, context),
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
                color: isFavorite ? AppColors.red : AppColors.lightGray,
                size: Responsive.scaleFont(26, context),
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
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // E’lon rasmi (agar mavjud bo‘lsa)
            if (widget.post.pictureUrl != null && widget.post.pictureUrl!.isNotEmpty)
              Container(
                height: Responsive.scaleHeight(220, context),
                width: double.infinity,
                margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.pictureUrl!.startsWith('http')
                        ? widget.post.pictureUrl!
                        : 'https://ishtopchi.uz${widget.post.pictureUrl}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: AppColors.lightBlue),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      LucideIcons.imageOff,
                      color: AppColors.lightGray,
                      size: Responsive.scaleFont(40, context),
                    ),
                  ),
                ),
              ),
            // Sarlavha
            Text(
              widget.post.title ?? 'Noma’lum',
              style: TextStyle(
                fontSize: Responsive.scaleFont(24, context),
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppDimensions.paddingSmall),
            // Holat va kategoriya
            Row(
              children: [
                if (widget.post.status != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(12, context),
                      vertical: Responsive.scaleHeight(6, context),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(widget.post.status!).withOpacity(0.3),
                          _getStatusColor(widget.post.status!).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      border: Border.all(color: _getStatusColor(widget.post.status!), width: 1),
                    ),
                    child: Text(
                      widget.post.status!.toUpperCase(),
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(12, context),
                        color: _getStatusColor(widget.post.status!),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (widget.post.category != null) ...[
                  SizedBox(width: AppDimensions.paddingSmall),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(12, context),
                      vertical: Responsive.scaleHeight(6, context),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightBlue.withOpacity(0.3),
                          AppColors.lightBlue.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                      border: Border.all(color: AppColors.lightBlue, width: 1),
                    ),
                    child: Text(
                      widget.post.category!.title ?? 'Noma’lum',
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(12, context),
                        color: AppColors.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            // Tavsif
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.post.content ?? 'Tavsif yo‘q',
                style: TextStyle(
                  fontSize: Responsive.scaleFont(16, context),
                  color: AppColors.lightGray,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            // Maosh va joylashuv
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.wallet,
                        size: Responsive.scaleFont(18, context),
                        color: AppColors.lightBlue,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Text(
                        '${widget.post.salaryFrom ?? 'Noma’lum'} - ${widget.post.salaryTo ?? 'Noma’lum'} UZS',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(16, context),
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: Responsive.scaleFont(18, context),
                        color: AppColors.lightBlue,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Text(
                        widget.post.district?.name ?? 'Noma’lum tuman',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(16, context),
                          color: AppColors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.post.location?.title != null) ...[
              SizedBox(height: AppDimensions.paddingSmall),
              Row(
                children: [
                  Icon(
                    LucideIcons.map,
                    size: Responsive.scaleFont(18, context),
                    color: AppColors.lightBlue,
                  ),
                  SizedBox(width: Responsive.scaleWidth(8, context)),
                  Expanded(
                    child: Text(
                      widget.post.location!.title!,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(15, context),
                        color: AppColors.lightGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: AppDimensions.paddingMedium),
            // Xarita
            Obx(() => Container(
              height: Responsive.scaleHeight(300, context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController.mapController,
                      options: MapOptions(
                        initialCenter: controller.selectedLocation.value ?? LatLng(41.3111, 69.2401),
                        initialZoom: controller.currentZoom.value,
                        onMapReady: () {
                          controller.isMapReady.value = true;
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'torex.top.ishtopchi',
                          tileProvider: CachedTileProvider(),
                        ),
                        Obx(() => MarkerLayer(
                          markers: [
                            if (controller.currentLocation.value != null)
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: controller.currentLocation.value!,
                                child: const Icon(
                                  LucideIcons.locateFixed,
                                  color: Colors.blue,
                                  size: 20.0,
                                ),
                              ),
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: controller.selectedLocation.value ?? LatLng(41.3111, 69.2401),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 30.0,
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
                            backgroundColor: AppColors.darkBlue,
                            onPressed: () => controller.zoomIn(_moveMap),
                            child: Icon(
                              LucideIcons.plus,
                              color: AppColors.lightGray,
                              size: Responsive.scaleFont(18, context),
                            ),
                          ),
                          SizedBox(height: AppDimensions.paddingSmall),
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: AppColors.darkBlue,
                            onPressed: () => controller.zoomOut(_moveMap),
                            child: Icon(
                              LucideIcons.minus,
                              color: AppColors.lightGray,
                              size: Responsive.scaleFont(18, context),
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
                        backgroundColor: AppColors.darkBlue,
                        elevation: 2,
                        onPressed: () => controller.getCurrentLocation(_moveMap),
                        tooltip: 'Joriy joylashuvni aniqlash',
                        child: Icon(
                          LucideIcons.locate,
                          color: Colors.blue,
                          size: Responsive.scaleFont(18, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            SizedBox(height: AppDimensions.paddingMedium),
            // Bog‘lanish ma’lumotlari
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bog‘lanish uchun',
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(16, context),
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
                            size: Responsive.scaleFont(18, context),
                            color: AppColors.lightBlue,
                          ),
                          SizedBox(width: Responsive.scaleWidth(8, context)),
                          Text(
                            widget.post.phoneNumber!,
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(15, context),
                              color: AppColors.white,
                              decoration: TextDecoration.underline,
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
                            size: Responsive.scaleFont(18, context),
                            color: AppColors.lightBlue,
                          ),
                          SizedBox(width: Responsive.scaleWidth(8, context)),
                          Text(
                            widget.post.email!,
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(15, context),
                              color: AppColors.white,
                              decoration: TextDecoration.underline,
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
            // Qo‘shimcha ma’lumotlar
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qo‘shimcha ma’lumotlar',
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(16, context),
                      color: AppColors.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.eye,
                        size: Responsive.scaleFont(16, context),
                        color: AppColors.lightGray,
                      ),
                      SizedBox(width: Responsive.scaleWidth(8, context)),
                      Text(
                        '${widget.post.views ?? 0} ko‘rish',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(14, context),
                          color: AppColors.lightGray,
                        ),
                      ),
                    ],
                  ),
                  if (widget.post.createdAt != null) ...[
                    SizedBox(height: AppDimensions.paddingSmall),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.lightGray,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text(
                          'Joylashtirilgan: ${widget.post.createdAt!.substring(0, 10)}',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(14, context),
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.post.updatedAt != null) ...[
                    SizedBox(height: AppDimensions.paddingSmall),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.refreshCw,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.lightGray,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text(
                          'Yangilangan: ${widget.post.updatedAt!.substring(0, 10)}',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(14, context),
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppDimensions.paddingMedium),
            // Foydalanuvchi ma’lumotlari
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: Responsive.scaleWidth(24, context),
                    backgroundImage: widget.post.user?.profilePicture != null
                        ? NetworkImage(funcController.getProfileUrl(widget.post.user!.profilePicture))
                        : null,
                    backgroundColor: AppColors.darkBlue,
                    child: widget.post.user?.profilePicture == null
                        ? Icon(
                      LucideIcons.user,
                      size: Responsive.scaleFont(24, context),
                      color: AppColors.lightGray,
                    )
                        : null,
                  ),
                  SizedBox(width: Responsive.scaleWidth(12, context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(16, context),
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.post.email != null) ...[
                          SizedBox(height: AppDimensions.paddingSmall),
                          Text(
                            widget.post.email!,
                            style: TextStyle(
                              fontSize: Responsive.scaleFont(14, context),
                              color: AppColors.lightGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
        return AppColors.lightGray;
    }
  }
}