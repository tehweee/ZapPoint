import 'dart:convert';
import 'package:http/http.dart' as http;
import 'GetVehicleDetails.dart';

class HttpServiceVehicleDetails {
  static const Map<String, String> _headers = {
    'x-rapidapi-key': 'f8f1cc1c8emsh8ce076a6136ca13p116ff2jsn1f2f9b873075',
    'x-rapidapi-host': 'cars-database-with-image.p.rapidapi.com',
  };
  static Future<GetVehicleDetails?> getVehicleDetails(String? carId) async {
    final String _baseUrl =
        'https://cars-database-with-image.p.rapidapi.com/api/car/$carId';
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);

        // Parse the single vehicle object
        final vehicle = GetVehicleDetails.fromJson(jsonBody);
        return vehicle;
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
