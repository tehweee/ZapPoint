import 'dart:convert';

GetVehicles getVehiclesFromJson(String str) =>
    GetVehicles.fromJson(json.decode(str));

String getVehiclesToJson(GetVehicles data) => json.encode(data.toJson());

class GetVehicles {
  List<Result> results;
  int page;

  GetVehicles({required this.results, required this.page});

  factory GetVehicles.fromJson(Map<String, dynamic> json) => GetVehicles(
    results: List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
    page: json["page"],
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "page": page,
  };
}

class Result {
  String id;
  String title;
  String content;
  String additional;
  String image;
  String wr;

  Result({
    required this.id,
    required this.title,
    required this.content,
    required this.additional,
    required this.image,
    required this.wr,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    additional: json["additional"],
    image: json["image"],
    wr: json["wr"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "additional": additional,
    "image": image,
    "wr": wr,
  };
}
