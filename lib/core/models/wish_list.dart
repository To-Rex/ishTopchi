import 'package:ishtopchi/core/models/post_model.dart';

class WishList {
  final int? id;
  final String? title;
  final String? content;
  final String? phoneNumber;
  final String? email;
  final String? pictureUrl;
  final String? salaryFrom;
  final String? salaryTo;
  final bool? isOpen;
  final String? status;
  final int? views;
  final String? jobType;
  final String? employmentType;
  final String? createdAt;
  final String? updatedAt;
  final User? user;
  final Location? location;
  final Category? category;
  final District? district;

  WishList({this.id, this.title, this.content, this.phoneNumber, this.email, this.pictureUrl, this.salaryFrom, this.salaryTo, this.isOpen, this.status, this.views, this.jobType, this.employmentType, this.createdAt, this.updatedAt, this.user, this.location, this.category, this.district});

  factory WishList.fromJson(Map<String, dynamic> json) {
    return WishList(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      pictureUrl: json['picture_url'],
      salaryFrom: json['salary_from'],
      salaryTo: json['salary_to'],
      isOpen: json['is_open'],
      status: json['status'],
      views: json['views'],
      jobType: json['job_type'],
      employmentType: json['employment_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      district: json['district'] != null ? District.fromJson(json['district']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['picture_url'] = pictureUrl;
    data['salary_from'] = salaryFrom;
    data['salary_to'] = salaryTo;
    data['is_open'] = isOpen;
    data['status'] = status;
    data['views'] = views;
    data['job_type'] = jobType;
    data['employment_type'] = employmentType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (district != null) {
      data['district'] = district!.toJson();
    }
    return data;
  }
}