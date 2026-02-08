import 'package:flutter/foundation.dart';
import 'package:ishtopchi/core/models/post_model.dart';
import 'package:ishtopchi/core/models/resumes_model.dart';

class ChatRooms {
  final Data data;

  ChatRooms({required this.data});

  factory ChatRooms.fromJson(Map<String, dynamic> json) {
    return ChatRooms(data: Data.fromJson(json['data']));
  }
}

class Data {
  final List<PostOwnerRoom> postOwnerRooms;
  final List<ApplicationRoom> applicationRooms;
  final List<OtherRoom> otherRooms;
  final Meta meta;

  Data({
    required this.postOwnerRooms,
    required this.applicationRooms,
    required this.otherRooms,
    required this.meta,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      postOwnerRooms:
          (json['postOwnerRooms'] as List)
              .map((e) => PostOwnerRoom.fromJson(e))
              .toList(),
      applicationRooms:
          (json['applicationRooms'] as List)
              .map((e) => ApplicationRoom.fromJson(e))
              .toList(),
      otherRooms:
          (json['otherRooms'] as List)
              .map((e) => OtherRoom.fromJson(e))
              .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class PostOwnerRoom {
  final Post post;
  final List<ChatRoom> chatRooms;

  PostOwnerRoom({required this.post, required this.chatRooms});

  factory PostOwnerRoom.fromJson(Map<String, dynamic> json) {
    return PostOwnerRoom(
      post: Post.fromJson(json['post']),
      chatRooms:
          (json['chatRooms'] as List).map((e) => ChatRoom.fromJson(e)).toList(),
    );
  }
}

class ChatRoom {
  final int id;
  final User user1;
  final User user2;
  final Application application;
  final String createdAt;
  final String updatedAt;
  final bool isApplicantRejected;

  ChatRoom({
    required this.id,
    required this.user1,
    required this.user2,
    required this.application,
    required this.createdAt,
    required this.updatedAt,
    required this.isApplicantRejected,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application: Application.fromJson(json['application']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isApplicantRejected: json['is_applicant_rejected'] ?? false,
    );
  }
}

class ApplicationRoom {
  final int id;
  final User user1;
  final User user2;
  final Application application;
  final String createdAt;
  final String updatedAt;
  final bool isApplicantRejected;

  ApplicationRoom({
    required this.id,
    required this.user1,
    required this.user2,
    required this.application,
    required this.createdAt,
    required this.updatedAt,
    required this.isApplicantRejected,
  });

  factory ApplicationRoom.fromJson(Map<String, dynamic> json) {
    return ApplicationRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application: Application.fromJson(json['application']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isApplicantRejected: json['is_applicant_rejected'] ?? false,
    );
  }
}

class OtherRoom {
  final int id;
  final User user1;
  final User user2;
  final Application? application;
  final String createdAt;
  final String updatedAt;
  final bool isApplicantRejected;

  OtherRoom({
    required this.id,
    required this.user1,
    required this.user2,
    this.application,
    required this.createdAt,
    required this.updatedAt,
    required this.isApplicantRejected,
  });

  factory OtherRoom.fromJson(Map<String, dynamic> json) {
    return OtherRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application:
          json['application'] != null
              ? Application.fromJson(json['application'])
              : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isApplicantRejected: json['is_applicant_rejected'] ?? false,
    );
  }
}

class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? profilePicture;
  final String? birthDate;
  final String? gender;
  final bool verified;
  final bool isBlocked;
  final String? role;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.profilePicture,
    this.birthDate,
    this.gender,
    required this.verified,
    required this.isBlocked,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] as String?,
      profilePicture: json['profile_picture'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      verified: json['verified'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      role: json['role'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
      deletedAt: json['deletedAt'] as String?,
    );
  }
}

class Application {
  final int id;
  final String? status;
  final String? message;
  final User applicant;
  final Post post;
  final ResumesData? resume;
  final String createdAt;
  final String updatedAt;

  Application({
    required this.id,
    this.status,
    this.message,
    required this.applicant,
    required this.post,
    this.resume,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      applicant: User.fromJson(json['applicant'] ?? {}),
      post: Post.fromJson(json['post'] ?? {}),
      resume:
          json['resume'] != null ? ResumesData.fromJson(json['resume']) : null,
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class Post {
  final int id;
  final String? title;
  final String? content;
  final String? phoneNumber;
  final String? email;
  final String? pictureUrl;
  final String? salaryFrom;
  final String? salaryTo;
  final bool isOpen;
  final String? status;
  final int views;
  final String? jobType;
  final String? employmentType;
  final String createdAt;
  final String updatedAt;
  final User user;

  Post({
    required this.id,
    this.title,
    this.content,
    this.phoneNumber,
    this.email,
    this.pictureUrl,
    this.salaryFrom,
    this.salaryTo,
    required this.isOpen,
    this.status,
    required this.views,
    this.jobType,
    this.employmentType,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      phoneNumber: json['phone_number'],
      email: json['email'],
      pictureUrl: json['picture_url'],
      salaryFrom: json['salary_from']?.toString() ?? '0',
      salaryTo: json['salary_to']?.toString() ?? '0',
      isOpen: json['is_open'] ?? false,
      status: json['status'] ?? '',
      views: json['views'] ?? 0,
      jobType: json['job_type'],
      employmentType: json['employment_type'],
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] ?? DateTime.now().toIso8601String(),
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class Meta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Meta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
