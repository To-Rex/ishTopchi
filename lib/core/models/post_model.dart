import 'user_model.dart';
import 'category_model.dart';
import 'district_model.dart';
import 'location_model.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final String? phoneNumber;
  final String? email;
  final String salaryFrom;
  final String salaryTo;
  final bool isOpen;
  final String status;
  final int views;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final Category? category;
  final District? district;
  final Location? location;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.phoneNumber,
    this.email,
    required this.salaryFrom,
    required this.salaryTo,
    required this.isOpen,
    required this.status,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.category,
    this.district,
    this.location,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      salaryFrom: json['salary_from'],
      salaryTo: json['salary_to'],
      isOpen: json['is_open'],
      status: json['status'],
      views: json['views'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      district: json['district'] != null ? District.fromJson(json['district']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }
}