import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing_rapidapi_2/const.dart';
import 'GetVehicles.dart';

class HttpServiceVehicles {
  static const String _baseUrl =
      'https://cars-database-with-image.p.rapidapi.com/api/search/advanced?fuel=6';

  static final Map<String, String> _headers = {
    'x-rapidapi-key': VEHICLE_INFO_API,
    'x-rapidapi-host': 'cars-database-with-image.p.rapidapi.com',
  };

  static Future<List<Result>?> getVehicles() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['results'] as List;
        print('Parsed ${data.length} vehicles');
        return data.map((item) => Result.fromJson(item)).toList();
      } else {
        print('Failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }
}
