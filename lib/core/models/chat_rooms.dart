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
      postOwnerRooms: (json['postOwnerRooms'] as List).map((e) => PostOwnerRoom.fromJson(e)).toList(),
      applicationRooms: (json['applicationRooms'] as List).map((e) => ApplicationRoom.fromJson(e)).toList(),
      otherRooms: (json['otherRooms'] as List).map((e) => OtherRoom.fromJson(e)).toList(),
      meta: Meta.fromJson(json['meta'])
    );
  }
}

class PostOwnerRoom {
  final int id;
  final User user1;
  final User user2;
  final Application application;
  final String createdAt;
  final String updatedAt;

  PostOwnerRoom({
    required this.id,
    required this.user1,
    required this.user2,
    required this.application,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostOwnerRoom.fromJson(Map<String, dynamic> json) {
    return PostOwnerRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application: Application.fromJson(json['application']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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

  ApplicationRoom({
    required this.id,
    required this.user1,
    required this.user2,
    required this.application,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationRoom.fromJson(Map<String, dynamic> json) {
    return ApplicationRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application: Application.fromJson(json['application']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at']
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

  OtherRoom({
    required this.id,
    required this.user1,
    required this.user2,
    this.application,
    required this.createdAt,
    required this.updatedAt
  });

  factory OtherRoom.fromJson(Map<String, dynamic> json) {
    return OtherRoom(
      id: json['id'],
      user1: User.fromJson(json['user1']),
      user2: User.fromJson(json['user2']),
      application: json['application'] != null ? Application.fromJson(json['application']) : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at']
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String profilePicture;
  final String birthDate;
  final String? gender;
  final bool verified;
  final bool isBlocked;
  final String role;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.birthDate,
    this.gender,
    required this.verified,
    required this.isBlocked,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      verified: json['verified'],
      isBlocked: json['is_blocked'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
    );
  }
}

class Application {
  final int id;
  final String status;
  final String message;
  final User applicant;
  final Post post;
  final Resumes resume;
  final String createdAt;
  final String updatedAt;

  Application({
    required this.id,
    required this.status,
    required this.message,
    required this.applicant,
    required this.post,
    required this.resume,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      status: json['status'],
      message: json['message'],
      applicant: User.fromJson(json['applicant']),
      post: Post.fromJson(json['post']),
      resume: Resumes.fromJson(json['resume']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Post {
  final int id;
  final String title;
  final String content;
  final String? phoneNumber;
  final String? email;
  final String? pictureUrl;
  final String salaryFrom;
  final String salaryTo;
  final bool isOpen;
  final String status;
  final int views;
  final String? jobType;
  final String? employmentType;
  final String createdAt;
  final String updatedAt;
  final User user;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.phoneNumber,
    this.email,
    this.pictureUrl,
    required this.salaryFrom,
    required this.salaryTo,
    required this.isOpen,
    required this.status,
    required this.views,
    this.jobType,
    this.employmentType,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
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
      user: User.fromJson(json['user']),
    );
  }
}