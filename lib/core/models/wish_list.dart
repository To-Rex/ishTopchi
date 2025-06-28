import 'package:ishtopchi/core/models/post_model.dart';

class WishList {
  final int id;
  final int userId;
  final int postId;
  final String createdAt;
  final String updatedAt;
  final Post post;
  final User? user;

  WishList({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.post,
    this.user,
  });

  factory WishList.fromJson(Map<String, dynamic> json) {
    return WishList(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      post: Post.fromJson(json['post']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}