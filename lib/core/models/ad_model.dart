class AdModel {
  final String id;
  final String title;
  final String description;
  final String region;
  final String postedDate;
  final double? salary;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.region,
    required this.postedDate,
    this.salary,
  });
}
