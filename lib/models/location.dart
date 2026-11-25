class Location {
  const Location({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.region,
    this.country,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? region;
  final String? country;

  String get subtitle => [region, country]
      .where((part) => part != null && part.isNotEmpty)
      .join(', ');

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'].toString(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      region: json['admin1'] as String?,
      country: json['country'] as String?,
    );
  }

  factory Location.fromStoredJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      region: json['region'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'region': region,
        'country': country,
      };
}
