import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import 'package:ishtopchi/modules/profile/views/create_resume_screen.dart';
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
    final latitude = widget.post.location?.latitude is String ? double.tryParse(widget.post.location!.latitude!) : widget.post.location?.latitude as double?;
    final longitude = widget.post.location?.longitude is String ? double.tryParse(widget.post.location!.longitude!) : widget.post.location?.longitude as double?;
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

  void _showApplicationDialog(BuildContext context, ApiController apiController, int postId) {
    final FuncController funcController = Get.find<FuncController>();
    final TextEditingController messageController = TextEditingController();
    final RxInt selectedResumeId = (-1).obs; // Tanlangan resume IDsi

    // Resumelarni olish
    apiController.fetchMeResumes(page: 1, limit: 100);

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.darkNavy,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkNavy], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1, offset: Offset(0, 3))]
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sarlavha
                Text('Murojaat qilish', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(18, context), fontWeight: FontWeight.w800)),
                SizedBox(height: AppDimensions.paddingSmall),
                // Resume tanlash
                Obx(() {
                  if (funcController.isLoading.value) {
                    return Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2));
                  }
                  if (funcController.resumes.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rezumelar mavjud emas', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context))),
                        SizedBox(height: AppDimensions.paddingSmall),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.to(CreateResumeScreen());
                          },
                          child: Text('Yangi resume qo‘shish', style: TextStyle(color: AppColors.lightBlue, fontSize: Responsive.scaleFont(14, context)))
                        )
                      ]
                    );
                  }
                  return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Resume tanlang',
                      labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius), borderSide: BorderSide(color: AppColors.lightBlue)),
                      filled: true,
                      fillColor: AppColors.darkNavy,
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius), borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.5)),
                    ),
                    dropdownColor: AppColors.darkNavy,
                    value: selectedResumeId.value == -1 ? null : selectedResumeId.value,
                    items: funcController.resumes.map((resume) => DropdownMenuItem<int>(value: resume.id, child: Text(resume.title ?? 'Noma’lum', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context)), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (value) {
                      selectedResumeId.value = value ?? -1;
                    }
                  );
                }),
                SizedBox(height: AppDimensions.paddingSmall),
                // Xabar yozish
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Xabar',
                    labelStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(14, context)),
                    hintText: 'Murojaat xabarini kiriting',
                    hintStyle: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius), borderSide: BorderSide(color: AppColors.lightBlue)),
                    filled: true,
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius), borderSide: const BorderSide(color: AppColors.lightBlue, width: 1.5)),
                    fillColor: AppColors.darkNavy
                  ),
                  style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context))
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // Tugmalar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Bekor qilish', style: TextStyle(color: AppColors.red, fontSize: Responsive.scaleFont(14, context)))
                    ),
                    SizedBox(width: AppDimensions.paddingSmall),
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.lightBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius)),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center,
                            fixedSize: Size(Responsive.scaleWidth(100, context), Responsive.scaleHeight(40, context))
                        ),
                        onPressed: () async {
                          if (selectedResumeId.value == -1) {
                            ShowToast.show('Xatolik', 'Iltimos, resume tanlang', 1, 1);
                            return;
                          }
                          if (messageController.text.trim().isEmpty) {
                            ShowToast.show('Xatolik', 'Iltimos, xabar kiriting', 1, 1);
                            return;
                          }
                          Get.back();
                          await apiController.createApplication(postId, messageController.text.trim(), selectedResumeId.value);
                        },
                        child: Text('Yuborish', style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w600))
                    )
                  ]
                )
              ]
            )
          )
        )
      )
    );
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
        leading: IconButton(icon: Icon(LucideIcons.arrowLeft, color: AppColors.white, size: Responsive.scaleFont(22, context)),onPressed: () => Get.back(),),
        title: Text('E‘lon tafsilotlari',style: TextStyle(color: AppColors.white,fontSize: Responsive.scaleFont(18, context),fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Obx(() {
            final isFavorite = funcController.wishList.any((w) => w.id == widget.post.id);
            return IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,color: isFavorite ? AppColors.red : AppColors.lightGray,size: Responsive.scaleFont(22, context)),
              onPressed: () async {
                if (isFavorite) {
                  await apiController.removeFromWishlist(widget.post.id!.toInt());
                } else {
                  await apiController.addToWishlist(widget.post.id!.toInt());
                }
              }
            );
          })
        ]
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: AppDimensions.paddingSmall),
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 200),
              childAnimationBuilder: (widget) => SlideAnimation(verticalOffset: 30.0,child: FadeInAnimation(child: widget)),
              children: [
                // 1. Surat
                if (widget.post.pictureUrl != null && widget.post.pictureUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: Responsive.scaleHeight(200, context),
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: widget.post.pictureUrl!.startsWith('http') ? widget.post.pictureUrl! : 'https://ishtopchi.uz${widget.post.pictureUrl}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
                        errorWidget: (context, url, error) => Container(
                          height: Responsive.scaleHeight(200, context),
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Icon(LucideIcons.imageOff, size: Responsive.scaleFont(48, context), color: AppColors.lightGray))
                        )
                      )
                    )
                  ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 2. Sarlavha
                Text(
                  widget.post.title ?? 'Noma’lum',
                  style: TextStyle(fontSize: Responsive.scaleFont(22, context), fontWeight: FontWeight.w700, color: AppColors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 3. ish turi
                if (widget.post.jobType != null)
                  Row(
                    children: [
                      Icon(LucideIcons.briefcaseBusiness, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Text(widget.post.jobType == 'FULL_TIME' ? 'To‘liq ish kuni' : widget.post.jobType == 'TEMPORARY' ? 'Vaqtinchalik ish' : widget.post.jobType == 'REMOTE' ? 'Masofaviy ish' : widget.post.jobType == 'DAILY' ? 'Kunlik ish' : widget.post.jobType == 'PROJECT_BASED' ? 'Loyihaviy ish' : widget.post.jobType == 'INTERNSHIP' ? 'Amaliyot' : 'Noma’lum',style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.white))
                    ]
                  ),
                if (widget.post.jobType != null)
                  SizedBox(height: AppDimensions.paddingSmall),
                // 3. ish turi
                if (widget.post.employmentType != null)
                Row(
                    children: [
                      Icon(LucideIcons.briefcase, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Text(widget.post.employmentType == 'FULL_TIME' ? 'To‘liq ish kuni' : widget.post.employmentType == 'PART_TIME' ? 'Yarim stavka' : widget.post.employmentType == 'SHIFT_BASED' ? 'Smenali ish' : widget.post.employmentType == 'FLEXIBLE' ? 'Moslashuvchan ish' : widget.post.employmentType == 'REGULAR_SCHEDULE' ? 'Doimiy jadval' : 'Noma’lum', style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.white))
                    ]
                ),
                if (widget.post.employmentType != null)
                  SizedBox(height: AppDimensions.paddingSmall),
                // 3. Joylashtirilgan vaqt
                if (widget.post.createdAt != null)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: Responsive.scaleFont(16, context),
                        color: AppColors.lightGray,
                      ),
                      SizedBox(width: Responsive.scaleWidth(6, context)),
                      Text(
                        'Joylashtirilgan: ${widget.post.createdAt!.substring(0, 10)}',
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(13, context),
                          color: AppColors.lightGray,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 4. Ish haqi
                Row(
                  children: [
                    Icon(LucideIcons.wallet, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue),
                    SizedBox(width: Responsive.scaleWidth(6, context)),
                    Text('${widget.post.salaryFrom ?? 'Noma’lum'} - ${widget.post.salaryTo ?? 'Noma’lum'} UZS', style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: AppColors.white, fontWeight: FontWeight.w600))
                  ]
                ),
                SizedBox(height: AppDimensions.paddingSmall),
                // 5. Joylashuv
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue,),
                    SizedBox(width: Responsive.scaleWidth(6, context)),
                    Expanded(
                      child: Text(
                        widget.post.district?.name ?? widget.post.location?.title ?? 'Noma’lum tuman',
                        style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: AppColors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis
                      )
                    )
                  ]
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 6. Tavsif
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(12)),
                  child: Text(widget.post.content ?? 'Tavsif yo‘q', style: TextStyle(fontSize: Responsive.scaleFont(15, context), color: AppColors.lightGray, height: 1.6))
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 7. Bog‘lanish uchun
                Text(
                  'Bog‘lanish uchun',
                  style: TextStyle(
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
                        Icon(LucideIcons.phone, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue),
                        SizedBox(width: Responsive.scaleWidth(6, context)),
                        Text(widget.post.phoneNumber!, style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.white, decoration: TextDecoration.underline, decorationColor: AppColors.lightBlue))
                      ]
                    )
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
                        Icon(LucideIcons.mail, size: Responsive.scaleFont(16, context), color: AppColors.lightBlue),
                        SizedBox(width: Responsive.scaleWidth(6, context)),
                        Text(widget.post.email!, style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.white, decoration: TextDecoration.underline, decorationColor: AppColors.lightBlue))
                      ]
                    )
                  )
                ],
                SizedBox(height: AppDimensions.paddingMedium),
                AnimationConfiguration.staggeredList(
                  position: 10, // Mos index
                  duration: const Duration(milliseconds: 200),
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppDimensions.cardRadius), color: AppColors.lightBlue),
                          child: ElevatedButton(
                              onPressed: () => _showApplicationDialog(context, apiController, widget.post.id!),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius))),
                              child: Text('Murojaat qilish', textAlign: TextAlign.center, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w600))
                          )
                        )
                      )
                    )
                  )
                ),
                SizedBox(height: AppDimensions.paddingMedium),
                // 8. Foydalanuvchi ismi
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: Responsive.scaleWidth(20, context),
                      backgroundImage: widget.post.user?.profilePicture != null ? NetworkImage(funcController.getProfileUrl(widget.post.user!.profilePicture)) : null,
                      backgroundColor: AppColors.darkBlue,
                      child: widget.post.user?.profilePicture == null ? Icon(LucideIcons.user, size: Responsive.scaleFont(20, context), color: AppColors.lightGray) : null
                    ),
                    SizedBox(width: Responsive.scaleWidth(8, context)),
                    Expanded(child: Text('${widget.post.user?.firstName ?? ''} ${widget.post.user?.lastName ?? ''}'.trim(), style: TextStyle(fontSize: Responsive.scaleFont(15, context), color: AppColors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis))
                  ]
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
                            onMapReady: () {
                              controller.isMapReady.value = true;
                            }
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                              userAgentPackageName: 'torex.top.ishtopchi',
                            ),
                            Obx(() => MarkerLayer(
                              markers: [
                                if (controller.currentLocation.value != null)
                                  Marker(
                                    width: 38.0,
                                    height: 38.0,
                                    point: controller.currentLocation.value!,
                                    child: const Icon(LucideIcons.locateFixed, color: Colors.blue, size: 18.0)
                                  ),
                                Marker(
                                  width: 38.0,
                                  height: 38.0,
                                  point: controller.selectedLocation.value ?? LatLng(41.3111, 69.2401),
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 28.0)
                                )
                              ]
                            ))
                          ]
                        ),
                        Positioned(
                          right: AppDimensions.paddingSmall,
                          top: AppDimensions.paddingSmall,
                          child: Column(
                            children: [
                              IconButton(
                                splashColor: AppColors.darkBlue,
                                color: AppColors.darkBlue,
                                splashRadius: 20,
                                style: IconButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius))),
                                icon: Icon(LucideIcons.plus, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
                                onPressed: () => controller.zoomIn(_moveMap),
                              ),
                              SizedBox(height: AppDimensions.paddingSmall),
                              IconButton(
                                splashColor: AppColors.darkBlue,
                                color: AppColors.darkBlue,
                                splashRadius: 20,
                                style: IconButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius))),
                                icon: Icon(LucideIcons.minus, color: AppColors.lightGray, size: Responsive.scaleFont(18, context)),
                                onPressed: () => controller.zoomOut(_moveMap)
                              )
                            ]
                          )
                        ),
                        Positioned(
                          right: AppDimensions.paddingSmall,
                          bottom: AppDimensions.paddingSmall,
                            child: IconButton(
                              splashColor: AppColors.darkBlue,
                              color: AppColors.darkBlue,
                              splashRadius: 20,
                              style: IconButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.cardRadius))),
                              icon: Icon(LucideIcons.locate, color: Colors.blue, size: Responsive.scaleFont(20, context)),
                              tooltip: 'Joriy joylashuvni aniqlash',
                              onPressed: () => controller.getCurrentLocation(_moveMap)
                            )
                        )
                      ]
                    )
                  )
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
                          Icon(LucideIcons.hash, size: Responsive.scaleFont(16, context), color: AppColors.lightGray),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text('ID: ${widget.post.id ?? 'Noma’lum'}', style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.lightGray))
                        ]
                      ),
                      SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Icon(LucideIcons.eye, size: Responsive.scaleFont(16, context), color: AppColors.lightGray),
                          SizedBox(width: Responsive.scaleWidth(6, context)),
                          Text('${widget.post.views ?? 0} ko‘rish', style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.lightGray))
                        ]
                      ),
                      SizedBox(height: AppDimensions.paddingSmall),
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Icon(LucideIcons.circleAlert, size: Responsive.scaleFont(16, context), color: AppColors.red),
                            SizedBox(width: Responsive.scaleWidth(6, context)),
                            Text('Shikoyat qilish', style: TextStyle(fontSize: Responsive.scaleFont(13, context), color: AppColors.red, decoration: TextDecoration.underline, decorationColor: AppColors.red))
                          ]
                        )
                      )
                    ]
                  )
                ),
                SizedBox(height: AppDimensions.paddingLarge)
              ]
            )
          )
        )
      )
    );
  }
}