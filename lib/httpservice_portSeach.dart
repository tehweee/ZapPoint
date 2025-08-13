import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ChargersSearch.dart';

class HttpServicePortSearch {
  static const Map<String, String> _headers = {
    'x-rapidapi-key': 'f72197243bmshf94cb6e9a6ce889p14da50jsn6ed480952fb4',
    'x-rapidapi-host': 'ev-charge-finder.p.rapidapi.com',
  };

  static Future<List<DatumSearch>?> getCarparks(type, area) async {
    try {
      String _baseUrl =
          'https://ev-charge-finder.p.rapidapi.com/search-by-location?near=$area Singapore&limit=20&type=$type';

      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = jsonBody['data'] as List ?? [];
        print('Parsed ${data.length} chargers');

        return data.map((item) => DatumSearch.fromJson(item)).toList();
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
