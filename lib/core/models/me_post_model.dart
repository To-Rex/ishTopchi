class MePostModel {
  List<MeData>? data;
  MeMeta? meta;

  MePostModel({this.data, this.meta});

  MePostModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MeData>[];
      json['data'].forEach((v) {
        data!.add(MeData.fromJson(v));
      });
    }
    meta = json['meta'] != null ? MeMeta.fromJson(json['meta']) : null;
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

class MeData implements MePostInterface {
  @override
  int? id;
  @override
  String? title;
  @override
  String? content;
  @override
  String? phoneNumber;
  @override
  String? email;
  @override
  String? pictureUrl;
  @override
  String? salaryFrom;
  @override
  String? salaryTo;
  @override
  bool? isOpen;
  @override
  String? status;
  @override
  int? views;
  @override
  String? jobType;
  @override
  String? employmentType;
  @override
  String? createdAt;
  @override
  String? updatedAt;
  @override
  MeUser? user;
  @override
  MeLocation? location;
  @override
  MeCategory? category;
  @override
  MeDistrict? district;

  MeData({this.id, this.title, this.content, this.phoneNumber, this.email, this.pictureUrl, this.salaryFrom, this.salaryTo, this.isOpen, this.status, this.views, this.jobType, this.employmentType, this.createdAt, this.updatedAt, this.user, this.location, this.category, this.district});

  MeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    pictureUrl = json['picture_url'];
    salaryFrom = json['salary_from'];
    salaryTo = json['salary_to'];
    isOpen = json['is_open'];
    status = json['status'];
    views = json['views'];
    jobType = json['job_type'];
    employmentType = json['employment_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? MeUser.fromJson(json['user']) : null;
    location = json['location'] != null ? MeLocation.fromJson(json['location']) : null;
    category = json['category'] != null ? MeCategory.fromJson(json['category']) : null;
    district = json['district'] != null ? MeDistrict.fromJson(json['district']) : null;
  }

  @override
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

class MeUser {
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

  MeUser({this.id, this.firstName, this.lastName, this.profilePicture, this.birthDate, this.gender, this.verified, this.isBlocked, this.role, this.createdAt, this.updatedAt, this.deletedAt});

  MeUser.fromJson(Map<String, dynamic> json) {
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

class MeLocation {
  int? locationId;
  String? title;
  String? latitude;
  String? longitude;

  MeLocation({this.locationId, this.title, this.latitude, this.longitude});

  MeLocation.fromJson(Map<String, dynamic> json) {
    locationId = json['location_id'];
    title = json['title'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location_id'] = locationId;
    data['title'] = title;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class MeCategory {
  int? id;
  String? title;

  MeCategory({this.id, this.title});

  MeCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}

class MeDistrict {
  int? id;
  String? name;
  MeRegion? region;

  MeDistrict({this.id, this.name, this.region});

  MeDistrict.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    region =
    json['region'] != null ? MeRegion.fromJson(json['region']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (region != null) {
      data['region'] = region!.toJson();
    }
    return data;
  }
}

class MeRegion {
  int? id;
  String? name;
  String? code;

  MeRegion({this.id, this.name, this.code});

  MeRegion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}

class MeMeta {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  MeMeta({this.total, this.page, this.limit, this.totalPages});

  MeMeta.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    return data;
  }
}

abstract class MePostInterface {
  int? get id;
  String? get title;
  String? get content;
  String? get phoneNumber;
  String? get email;
  String? get pictureUrl;
  String? get salaryFrom;
  String? get salaryTo;
  bool? get isOpen;
  String? get status;
  int? get views;
  String? get jobType;
  String? get employmentType;
  String? get createdAt;
  String? get updatedAt;
  MeUser? get user;
  MeLocation? get location;
  MeCategory? get category;
  MeDistrict? get district;
  Map<String, dynamic> toJson(); // toJson metodini qo‘shish
}
