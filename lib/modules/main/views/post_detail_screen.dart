import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/post_model.dart';
import '../../../core/utils/responsive.dart';
import '../../ad_posting/controllers/ad_posting_controller.dart';
import '../controllers/post_detail_controller.dart';



class PostDetailScreen extends StatefulWidget {
  final Post post;

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
        ? double.tryParse(widget.post.location!.latitude)
        : widget.post.location?.latitude as double?;
    final longitude = widget.post.location?.longitude is String
        ? double.tryParse(widget.post.location!.longitude)
        : widget.post.location?.longitude as double?;
    if (latitude != null && longitude != null) {
      controller.setInitialLocation(LatLng(latitude, longitude));
    }
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
    Responsive.debugScreenInfo(context);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: Responsive.scaleWidth(4, context),
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
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.scalePadding(16, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      widget.post.title,
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(24, context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final isFavorite = funcController.wishList.any((w) => w.id == widget.post.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.red : AppColors.lightGray,
                        size: Responsive.scaleFont(28, context),
                      ),
                      onPressed: () async {
                        if (isFavorite) {
                          await apiController.removeFromWishlist(widget.post.id.toInt());
                        } else {
                          await apiController.addToWishlist(widget.post.id.toInt());
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(8, context),
              ),
              child: Chip(
                label: Text(
                  widget.post.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(12, context),
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _getStatusColor(widget.post.status),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scalePadding(8, context),
                  vertical: Responsive.scaleHeight(4, context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(8, context),
              ),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: Responsive.scaleFont(16, context),
                  color: AppColors.lightGray,
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(8, context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maosh:',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(14, context),
                          color: AppColors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Responsive.scaleHeight(4, context)),
                      Text(
                        '${widget.post.salaryFrom ?? 'Noma’lum'} - ${widget.post.salaryTo ?? 'Noma’lum'} UZS',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(16, context),
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Joylashuv:',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(14, context),
                          color: AppColors.lightBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: Responsive.scaleHeight(4, context)),
                      Text(
                        widget.post.district?.name ?? 'Noma’lum tuman',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(16, context),
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() => Container(
              height: Responsive.scaleHeight(300, context),
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(16, context),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
                color: AppColors.darkBlue,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
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
                          userAgentPackageName: 'com.example.ishtopchi',
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
                                  LucideIcons.locateFixed, // Tuzatildi
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
                      right: Responsive.scaleWidth(10, context),
                      top: Responsive.scaleHeight(10, context),
                      child: Column(
                        children: [
                          FloatingActionButton(
                            mini: true,
                            heroTag: 'post_detail_zoom_in_${widget.post.id}',
                            backgroundColor: AppColors.darkBlue,
                            onPressed: () => controller.zoomIn(_moveMap),
                            child: Icon(
                              LucideIcons.plus,
                              color: AppColors.lightGray,
                              size: Responsive.scaleFont(18, context),
                            ),
                          ),
                          SizedBox(height: Responsive.scaleHeight(10, context)),
                          FloatingActionButton(
                            mini: true,
                            heroTag: 'post_detail_zoom_out_${widget.post.id}',
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
                      right: Responsive.scaleWidth(10, context),
                      bottom: Responsive.scaleHeight(10, context),
                      child: FloatingActionButton(
                        mini: true,
                        heroTag: 'post_detail_location_${widget.post.id}',
                        backgroundColor: AppColors.darkBlue,
                        onPressed: () => controller.getCurrentLocation(_moveMap),
                        tooltip: 'Joriy joylashuvni aniqlash',
                        child: Icon(
                          LucideIcons.locate,
                          color: Colors.blue,
                          size: Responsive.scaleFont(20, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(8, context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bog‘lanish uchun:',
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(14, context),
                      color: AppColors.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.scaleHeight(8, context)),
                  if (widget.post.phoneNumber != null)
                    Row(
                      children: [
                        Icon(
                          LucideIcons.phone,
                          size: Responsive.scaleFont(18, context),
                          color: AppColors.lightGray,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text(
                          widget.post.phoneNumber!,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(16, context),
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  if (widget.post.email != null) ...[
                    SizedBox(height: Responsive.scaleHeight(8, context)),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mail,
                          size: Responsive.scaleFont(18, context),
                          color: AppColors.lightGray,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text(
                          widget.post.email!,
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(16, context),
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.scalePadding(16, context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: Responsive.scaleWidth(24, context),
                    backgroundImage: NetworkImage(
                      funcController.getProfileUrl(widget.post.user?.profilePicture),
                    ),
                    backgroundColor: AppColors.darkBlue,
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
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Joylashtirilgan: ${widget.post.createdAt.toString().substring(0, 10)}',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(12, context),
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(16, context)),
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