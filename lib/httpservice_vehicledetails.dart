import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing_rapidapi_2/const.dart';
import 'GetVehicleDetails.dart';

class HttpServiceVehicleDetails {
  static final Map<String, String> _headers = {
    'x-rapidapi-key': VEHICLE_INFO_API,
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
