class UserMe {
  Data? data;

  UserMe({this.data});

  UserMe.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? firstName;
  String? lastName;
  String? profilePicture;
  String? birthDate;
  String? gender;
  bool? verified;
  bool? isBlocked;
  String? role;
  District? district;
  List<AuthProviders>? authProviders;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  Data({this.id, this.firstName, this.lastName, this.profilePicture, this.birthDate, this.gender, this.verified, this.isBlocked, this.role, this.district, this.authProviders, this.createdAt, this.updatedAt, this.deletedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    profilePicture = json['profile_picture'];
    birthDate = json['birth_date'];
    gender = json['gender'];
    verified = json['verified'];
    isBlocked = json['is_blocked'];
    role = json['role'];
    district = json['district'] != null
        ? District.fromJson(json['district'])
        : null;
    if (json['auth_providers'] != null) {
      authProviders = <AuthProviders>[];
      json['auth_providers'].forEach((v) {
        authProviders!.add(AuthProviders.fromJson(v));
      });
    }
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
    if (district != null) {
      data['district'] = district!.toJson();
    }
    if (authProviders != null) {
      data['auth_providers'] =
          authProviders!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['deletedAt'] = deletedAt;
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

class AuthProviders {
  int? id;
  String? useType;
  String? providerType;
  String? providersUserId;
  String? email;
  String? fullName;
  String? profilePicture;
  bool? inUse;
  String? accessToken;
  String? refreshToken;
  String? passwordHash;

  AuthProviders({this.id, this.useType, this.providerType, this.providersUserId, this.email, this.fullName, this.profilePicture, this.inUse, this.accessToken, this.refreshToken, this.passwordHash});

  AuthProviders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    useType = json['use_type'];
    providerType = json['provider_type'];
    providersUserId = json['providers_user_id'];
    email = json['email'];
    fullName = json['full_name'];
    profilePicture = json['profile_picture'];
    inUse = json['in_use'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    passwordHash = json['password_hash'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['use_type'] = useType;
    data['provider_type'] = providerType;
    data['providers_user_id'] = providersUserId;
    data['email'] = email;
    data['full_name'] = fullName;
    data['profile_picture'] = profilePicture;
    data['in_use'] = inUse;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    data['password_hash'] = passwordHash;
    return data;
  }
}
