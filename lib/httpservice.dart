import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Chargers.dart';

class HttpService {
  static const String _baseUrl =
      'https://ev-charge-finder.p.rapidapi.com/search-by-coordinates-point?lat=1.438&lng=103.786&limit=20';

  static const Map<String, String> _headers = {
    'x-rapidapi-key': 'f72197243bmshf94cb6e9a6ce889p14da50jsn6ed480952fb4',
    'x-rapidapi-host': 'ev-charge-finder.p.rapidapi.com',
  };

  static Future<List<Datum>?> getCarparks() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List;
        return data.map((item) => Datum.fromJson(item)).toList();
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
