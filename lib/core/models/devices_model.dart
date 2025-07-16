class DevicesModel {
  List<DevicesData>? data;
  DevicesModel({this.data});
  DevicesModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DevicesData>[];
      json['data'].forEach((v) => data!.add(DevicesData.fromJson(v)));
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) data['data'] = this.data!.map((v) => v.toJson()).toList();
    return data;
  }
}

class DevicesData {
  int? id;
  String? deviceId;
  String? fcmToken;
  String? deviceName;
  String? deviceModel;
  String? platform;
  String? lastLogin;
  bool? isActive;
  Owner? owner;
  String? createdAt;
  String? updatedAt;

  DevicesData({this.id, this.deviceId, this.fcmToken, this.deviceName, this.deviceModel, this.platform, this.lastLogin, this.isActive, this.owner, this.createdAt, this.updatedAt});

  DevicesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['deviceId'];
    fcmToken = json['fcmToken'];
    deviceName = json['deviceName'];
    deviceModel = json['deviceModel'];
    platform = json['platform'];
    lastLogin = json['lastLogin'];
    isActive = json['isActive'];
    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['deviceId'] = deviceId;
    data['fcmToken'] = fcmToken;
    data['deviceName'] = deviceName;
    data['deviceModel'] = deviceModel;
    data['platform'] = platform;
    data['lastLogin'] = lastLogin;
    data['isActive'] = isActive;
    if (owner != null) data['owner'] = owner!.toJson();
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Owner {
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

  Owner({this.id, this.firstName, this.lastName, this.profilePicture, this.birthDate, this.gender, this.verified, this.isBlocked, this.role, this.createdAt, this.updatedAt, this.deletedAt});

  Owner.fromJson(Map<String, dynamic> json) {
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
