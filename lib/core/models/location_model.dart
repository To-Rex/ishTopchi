class Location {
  final int locationId;
  final String title;
  final String latitude;
  final String longitude;

  Location({
    required this.locationId,
    required this.title,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['location_id'],
      title: json['title'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}