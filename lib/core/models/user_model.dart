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
  final int? age;
  final String? region;
  final String? district;

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
    this.age,
    this.region,
    this.district,
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
      age: json['age'],
      region: json['region'],
      district: json['district'],
    );
  }
}