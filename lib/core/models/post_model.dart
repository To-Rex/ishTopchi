class Post {
  List<Data>? data;
  Meta? meta;

  Post({this.data, this.meta});

  Post.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  int? id;
  String? title;
  String? content;
  String? phoneNumber;
  String? email;
  String? pictureUrl;
  String? salaryFrom;
  String? salaryTo;
  bool? isOpen;
  String? status;
  int? views;
  String? createdAt;
  String? updatedAt;
  User? user;
  Location? location;
  Category? category;
  District? district;

  Data(
      {this.id,
        this.title,
        this.content,
        this.phoneNumber,
        this.email,
        this.pictureUrl,
        this.salaryFrom,
        this.salaryTo,
        this.isOpen,
        this.status,
        this.views,
        this.createdAt,
        this.updatedAt,
        this.user,
        this.location,
        this.category,
        this.district});

  Data.fromJson(Map<String, dynamic> json) {
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
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    district = json['district'] != null
        ? District.fromJson(json['district'])
        : null;
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

  User(
      {this.id,
        this.firstName,
        this.lastName,
        this.profilePicture,
        this.birthDate,
        this.gender,
        this.verified,
        this.isBlocked,
        this.role,
        this.createdAt,
        this.updatedAt,
        this.deletedAt});

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

class Location {
  int? locationId;
  String? title;
  String? latitude;
  String? longitude;

  Location({this.locationId, this.title, this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
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

class Category {
  int? id;
  String? title;

  Category({this.id, this.title});

  Category.fromJson(Map<String, dynamic> json) {
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

class District {
  int? id;
  String? name;
  Region? region;

  District({this.id, this.name, this.region});

  District.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    region =
    json['region'] != null ? Region.fromJson(json['region']) : null;
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

class Region {
  int? id;
  String? name;
  String? code;

  Region({this.id, this.name, this.code});

  Region.fromJson(Map<String, dynamic> json) {
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

class Meta {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Meta({this.total, this.page, this.limit, this.totalPages});

  Meta.fromJson(Map<String, dynamic> json) {
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
