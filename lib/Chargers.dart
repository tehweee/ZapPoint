class Connector {
  final String type;
  final int total;
  final int available;
  final double kw;
  final String speed;

  Connector({
    required this.type,
    required this.total,
    required this.available,
    required this.kw,
    required this.speed,
  });

  factory Connector.fromJson(Map<String, dynamic> json) {
    return Connector(
      type: json['type'] ?? '',
      total: json['total'] ?? 0,
      available: json['available'] ?? 0,
      kw: (json['kw'] as num).toDouble(),
      speed: json['speed'] ?? '',
    );
  }

  @override
  String toString() =>
      '$type - $available/$total available, ${kw}kW ($speed)';
}

class Datum {
  final String id;
  final String name;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final double? rating;
  final int? reviewCount;
  final String? website;
  final String? photo;
  final String? placeLink;
  final List<Connector> connectors;

  Datum({
    required this.id,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.rating,
    this.reviewCount,
    this.website,
    this.photo,
    this.placeLink,
    required this.connectors,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      phoneNumber: json['phone_number'],
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'],
      website: json['website'],
      photo: json['photo'],
      placeLink: json['place_link'],
      connectors: (json['connectors'] as List<dynamic>? ?? [])
          .map((e) => Connector.fromJson(e))
          .toList(),
    );
  }

  @override
  String toString() =>
      'Datum(name: $name, lat: $latitude, lng: $longitude, connectors: $connectors)';
}
