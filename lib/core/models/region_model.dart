class Region {
  final int id;
  final String name;
  final String? code;

  Region({
    required this.id,
    required this.name,
    this.code,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}