import 'region_model.dart';

class District {
  final int id;
  final String name;
  final Region? region;

  District({
    required this.id,
    required this.name,
    this.region,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
    );
  }
}