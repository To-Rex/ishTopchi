class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final int? age;
  final String region;
  final String district;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.age,
    required this.region,
    required this.district,
  });
}
