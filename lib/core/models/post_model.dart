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
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String? lastName;
  final String? profilePicture;
  final String? birthDate;
  final bool verified;
  final bool isBlocked;
  final String role;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePicture,
    this.birthDate,
    required this.verified,
    required this.isBlocked,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      birthDate: json['birth_date'],
      verified: json['verified'],
      isBlocked: json['is_blocked'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Category {
  final int id;
  final String title;

  Category({required this.id, required this.title});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], title: json['title']);
  }
}

class District {
  final int id;
  final String name;

  District({required this.id, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(id: json['id'], name: json['name']);
  }
}