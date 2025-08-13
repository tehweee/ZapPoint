// To parse this JSON data, do
//
//     final chargersSearch = chargersSearchFromJson(jsonString);

import 'dart:convert';

ChargersSearch chargersSearchFromJson(String str) =>
    ChargersSearch.fromJson(json.decode(str));

String chargersSearchToJson(ChargersSearch data) => json.encode(data.toJson());

class ChargersSearch {
  String? status;
  String? requestId;
  List<DatumSearch>? data;

  ChargersSearch({this.status, this.requestId, this.data});

  factory ChargersSearch.fromJson(Map<String, dynamic> json) => ChargersSearch(
    status: json["status"],
    requestId: json["request_id"],
    data: json["data"] == null
        ? []
        : List<DatumSearch>.from(
            json["data"]!.map((x) => DatumSearch.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "request_id": requestId,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class DatumSearch {
  String? id;
  String? name;
  List<Connector>? connectors;
  String? formattedAddress;
  AddressComponents? addressComponents;
  double? latitude;
  double? longitude;
  String? placeLink;
  String? phoneNumber;
  OpeningHours? openingHours;
  double? rating;
  int? reviewCount;
  String? website;
  String? photo;
  String? googlePlaceId;
  String? googleCid;

  DatumSearch({
    this.id,
    this.name,
    this.connectors,
    this.formattedAddress,
    this.addressComponents,
    this.latitude,
    this.longitude,
    this.placeLink,
    this.phoneNumber,
    this.openingHours,
    this.rating,
    this.reviewCount,
    this.website,
    this.photo,
    this.googlePlaceId,
    this.googleCid,
  });

  factory DatumSearch.fromJson(Map<String, dynamic> json) => DatumSearch(
    id: json["id"],
    name: json["name"],
    connectors: json["connectors"] == null
        ? []
        : List<Connector>.from(
            json["connectors"]!.map((x) => Connector.fromJson(x)),
          ),
    formattedAddress: json["formatted_address"],
    addressComponents: json["address_components"] == null
        ? null
        : AddressComponents.fromJson(json["address_components"]),
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    placeLink: json["place_link"],
    phoneNumber: json["phone_number"],
    openingHours: json["opening_hours"] == null
        ? null
        : OpeningHours.fromJson(json["opening_hours"]),
    rating: json["rating"]?.toDouble(),
    reviewCount: json["review_count"],
    website: json["website"],
    photo: json["photo"],
    googlePlaceId: json["google_place_id"],
    googleCid: json["google_cid"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "connectors": connectors == null
        ? []
        : List<dynamic>.from(connectors!.map((x) => x.toJson())),
    "formatted_address": formattedAddress,
    "address_components": addressComponents?.toJson(),
    "latitude": latitude,
    "longitude": longitude,
    "place_link": placeLink,
    "phone_number": phoneNumber,
    "opening_hours": openingHours?.toJson(),
    "rating": rating,
    "review_count": reviewCount,
    "website": website,
    "photo": photo,
    "google_place_id": googlePlaceId,
    "google_cid": googleCid,
  };
}

class AddressComponents {
  District? district;
  String? streetAddress;
  City? city;
  String? zipcode;
  dynamic state;
  Country? country;

  AddressComponents({
    this.district,
    this.streetAddress,
    this.city,
    this.zipcode,
    this.state,
    this.country,
  });

  factory AddressComponents.fromJson(Map<String, dynamic> json) =>
      AddressComponents(
        district: json["district"] == null
            ? null
            : districtValues.map[json["district"]],
        streetAddress: json["street_address"],
        city: json["city"] == null ? null : cityValues.map[json["city"]],
        zipcode: json["zipcode"],
        state: json["state"],
        country: json["country"] == null
            ? null
            : countryValues.map[json["country"]],
      );

  Map<String, dynamic> toJson() => {
    "district": districtValues.reverse[district],
    "street_address": streetAddress,
    "city": cityValues.reverse[city],
    "zipcode": zipcode,
    "state": state,
    "country": countryValues.reverse[country],
  };
}

enum City { SINGAPORE }

final cityValues = EnumValues({"Singapore": City.SINGAPORE});

enum Country { SG }

final countryValues = EnumValues({"SG": Country.SG});

enum District { ANG_MO_KIO }

final districtValues = EnumValues({"Ang Mo Kio": District.ANG_MO_KIO});

class Connector {
  Type? type;
  int? total;
  int? available;
  int? kw;
  Speed? speed;

  Connector({this.type, this.total, this.available, this.kw, this.speed});

  factory Connector.fromJson(Map<String, dynamic> json) => Connector(
    type: json["type"] == null ? null : typeValues.map[json["type"]],
    total: json["total"],
    available: json["available"],
    kw: json["kw"],
    speed: json["speed"] == null ? null : speedValues.map[json["speed"]],
  );

  Map<String, dynamic> toJson() => {
    "type": typeValues.reverse[type],
    "total": total,
    "available": available,
    "kw": kw,
    "speed": speedValues.reverse[speed],
  };
}

enum Speed { FAST, MEDIUM, SLOW }

final speedValues = EnumValues({
  "Fast": Speed.FAST,
  "Medium": Speed.MEDIUM,
  "Slow": Speed.SLOW,
});

enum Type { CCS, TYPE_2 }

final typeValues = EnumValues({"CCS": Type.CCS, "Type 2": Type.TYPE_2});

class OpeningHours {
  List<Day>? thursday;
  List<Day>? friday;
  List<Day>? saturday;
  List<Day>? sunday;
  List<Day>? monday;
  List<Day>? tuesday;
  List<Day>? wednesday;

  OpeningHours({
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.monday,
    this.tuesday,
    this.wednesday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
    thursday: json["Thursday"] == null
        ? []
        : List<Day>.from(json["Thursday"]!.map((x) => dayValues.map[x]!)),
    friday: json["Friday"] == null
        ? []
        : List<Day>.from(json["Friday"]!.map((x) => dayValues.map[x]!)),
    saturday: json["Saturday"] == null
        ? []
        : List<Day>.from(json["Saturday"]!.map((x) => dayValues.map[x]!)),
    sunday: json["Sunday"] == null
        ? []
        : List<Day>.from(json["Sunday"]!.map((x) => dayValues.map[x]!)),
    monday: json["Monday"] == null
        ? []
        : List<Day>.from(json["Monday"]!.map((x) => dayValues.map[x]!)),
    tuesday: json["Tuesday"] == null
        ? []
        : List<Day>.from(json["Tuesday"]!.map((x) => dayValues.map[x]!)),
    wednesday: json["Wednesday"] == null
        ? []
        : List<Day>.from(json["Wednesday"]!.map((x) => dayValues.map[x]!)),
  );

  Map<String, dynamic> toJson() => {
    "Thursday": thursday == null
        ? []
        : List<dynamic>.from(thursday!.map((x) => dayValues.reverse[x])),
    "Friday": friday == null
        ? []
        : List<dynamic>.from(friday!.map((x) => dayValues.reverse[x])),
    "Saturday": saturday == null
        ? []
        : List<dynamic>.from(saturday!.map((x) => dayValues.reverse[x])),
    "Sunday": sunday == null
        ? []
        : List<dynamic>.from(sunday!.map((x) => dayValues.reverse[x])),
    "Monday": monday == null
        ? []
        : List<dynamic>.from(monday!.map((x) => dayValues.reverse[x])),
    "Tuesday": tuesday == null
        ? []
        : List<dynamic>.from(tuesday!.map((x) => dayValues.reverse[x])),
    "Wednesday": wednesday == null
        ? []
        : List<dynamic>.from(wednesday!.map((x) => dayValues.reverse[x])),
  };
}

enum Day { OPEN_24_HOURS, THE_830_AM_6_PM }

final dayValues = EnumValues({
  "Open 24 hours": Day.OPEN_24_HOURS,
  "8:30 am–6 pm": Day.THE_830_AM_6_PM,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
