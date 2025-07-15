import 'package:ishtopchi/core/models/post_model.dart';

class Resumes {
  List<ResumesData>? data;
  Meta? meta;

  Resumes({this.data, this.meta});

  Resumes.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ResumesData>[];
      json['data'].forEach((v) {
        data!.add(ResumesData.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class ResumesData {
  int? id;
  String? title;
  String? content;
  List<Education>? education;
  List<Experience>? experience;
  User? user;
  String? createdAt;
  String? updatedAt;
  String? fileUrl;

  ResumesData({this.id, this.title, this.content, this.education, this.experience, this.user, this.createdAt, this.updatedAt, this.fileUrl});

  ResumesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    if (json['education'] != null) {
      education = <Education>[];
      json['education'].forEach((v) {
        education!.add(Education.fromJson(v));
      });
    }
    if (json['experience'] != null) {
      experience = <Experience>[];
      json['experience'].forEach((v) {
        experience!.add(Experience.fromJson(v));
      });
    }
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fileUrl = json['file_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    if (education != null) {
      data['education'] = education!.map((v) => v.toJson()).toList();
    }
    if (experience != null) {
      data['experience'] = experience!.map((v) => v.toJson()).toList();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['file_url'] = fileUrl;
    return data;
  }
}

class Education {
  String? degree;
  String? field;
  String? institution;
  String? period;

  Education({this.degree, this.field, this.institution, this.period});

  Education.fromJson(Map<String, dynamic> json) {
    degree = json['degree'];
    field = json['field'];
    institution = json['institution'];
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['degree'] = degree;
    data['field'] = field;
    data['institution'] = institution;
    data['period'] = period;
    return data;
  }
}

class Experience {
  String? position;
  String? company;
  String? period;
  String? description;

  Experience({this.position, this.company, this.period, this.description});

  Experience.fromJson(Map<String, dynamic> json) {
    position = json['position'];
    company = json['company'];
    period = json['period'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['position'] = position;
    data['company'] = company;
    data['period'] = period;
    data['description'] = description;
    return data;
  }
}

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? profilePicture;
  String? birthDate;
  String? gender;
  bool? verified;
  bool? isBlocked;
  String? role;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  User({this.id, this.firstName, this.lastName, this.profilePicture, this.birthDate, this.gender, this.verified, this.isBlocked, this.role, this.createdAt, this.updatedAt, this.deletedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    profilePicture = json['profile_picture'];
    birthDate = json['birth_date'];
    gender = json['gender'];
    verified = json['verified'];
    isBlocked = json['is_blocked'];
    role = json['role'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['profile_picture'] = profilePicture;
    data['birth_date'] = birthDate;
    data['gender'] = gender;
    data['verified'] = verified;
    data['is_blocked'] = isBlocked;
    data['role'] = role;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
    return data;
  }
}