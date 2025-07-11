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

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate!
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{s}', options.subdomains.first);
    return NetworkImage(url);
  }
}

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
        physics: const BouncingScrollPhysics(),
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
                      widget.post.title ?? 'Noma’lum',
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
                          await apiController.removeFromWishlist(widget.post.id!.toInt());
                        } else {
                          await apiController.addToWishlist(widget.post.id!.toInt());
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
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleWidth(10, context),
                      vertical: Responsive.scaleHeight(4, context),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(widget.post.status ?? '').withOpacity(0.2),
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
                      border: Border.all(color: _getStatusColor(widget.post.status ?? '')),
                    ),
                    child: Text(
                      widget.post.status?.toUpperCase() ?? 'NOMA’LUM',
                      style: TextStyle(
                        fontSize: Responsive.scaleFont(12, context),
                        color: _getStatusColor(widget.post.status ?? ''),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.post.category != null) ...[
                    SizedBox(width: Responsive.scaleWidth(8, context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scaleWidth(10, context),
                        vertical: Responsive.scaleHeight(4, context),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
                        border: Border.all(color: AppColors.lightBlue),
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.scalePadding(16, context),
                vertical: Responsive.scaleHeight(8, context),
              ),
              child: Text(
                widget.post.content ?? 'Tavsif yo‘q',
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
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.wallet,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.lightBlue,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
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
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: Responsive.scaleFont(16, context),
                          color: AppColors.lightBlue,
                        ),
                        SizedBox(width: Responsive.scaleWidth(8, context)),
                        Text(
                          widget.post.district?.name ?? 'Noma’lum tuman',
                          style: TextStyle(
                            fontSize: Responsive.scaleFont(16, context),
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
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
                          tileProvider: CachedTileProvider(),
                          userAgentPackageName: 'com.example.ishtopchi',
                          tileSize: Responsive.scaleWidth(256, context),
                          maxNativeZoom: 19,
                          errorTileCallback: (tile, error, stackTrace) {
                            print('Xarita plitkasi xatosi: $error');
                          },
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
                  SizedBox(height: Responsive.scaleHeight(12, context)),
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
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Joylashtirilgan: ${widget.post.createdAt?.substring(0, 10) ?? 'Noma’lum'}',
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