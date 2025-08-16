import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ChargersSearch.dart';
import 'const.dart';

class HttpServicePortSearch {
  static final Map<String, String> _headers = {
    'x-rapidapi-key': EV_CHARGER_API,
    'x-rapidapi-host': 'ev-charge-finder.p.rapidapi.com',
  };

  static Future<List<DatumSearch>?> getCarparks(type, area) async {
    try {
      String _baseUrl =
          'https://ev-charge-finder.p.rapidapi.com/search-by-location?near=$area Singapore&limit=20&type=$type&available=true';

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

  static Future<List<DatumSearch>?> getFilterCarparks(
    type,
    area,
    min_kw,
    max_kw,
    limit,
  ) async {
    print("""
==================
==================
type: $type
area $area
min $min_kw
max $max_kw
limit $limit
==================
==================

""");
    try {
      String _baseUrl =
          'https://ev-charge-finder.p.rapidapi.com/search-by-location?near=$area Singapore&type=${type}&available=true&min_kw=$min_kw&max_kw=$max_kw&limit=$limit';

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
