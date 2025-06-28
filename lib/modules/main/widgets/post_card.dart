import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          // Postni ochish uchun qo‘shimcha logika qo‘shish mumkin
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sarlavha va yurakcha bir qatorda
              SizedBox(
                height: 40, // Maksimal balandlikni cheklamoq
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sarlavha uchun moslashuvchan kenglik
                    Flexible(
                      child: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Yurakcha tugmasi
                    Obx(() {
                      final isFavorite = funcController.wishList.any((w) => w.postId == post.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20, // Hajmini yanada kamaytirdik
                        ),
                        onPressed: () async {
                          if (isFavorite) {
                            await apiController.removeFromWishlist(post.id);
                          } else {
                            await apiController.addToWishlist(post.id);
                          }
                          // Wishlistni darhol yangilash
                          await apiController.fetchWishlist();
                        },
                        padding: const EdgeInsets.all(2), // Minimal padding
                        constraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Kontent
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              // Qo‘shimcha ma’lumotlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Maosh va tuman ma’lumotlari
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maosh: ${post.salaryFrom} - ${post.salaryTo} UZS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.district?.name ?? 'Noma’lum tuman',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}