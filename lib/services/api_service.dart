import 'dart:convert';
import 'package:cemantix/const.dart';
import 'package:cemantix/utils/utils.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> sendWord(String word) async {
    if (IS_TESTING && word.contains('test')) {
      final percent = word.replaceAll('test', '');
      final score = double.tryParse(percent) ?? 0.0;
      return {
        's': score / 1000,
        'v': 100 + (1000 * (1 - score / 100)).toInt(),
        'p': score,
      };
    }

    int todayCode = getTodaysCode();

    final url = Uri.parse('https://cemantix.certitudes.org/score?n=$todayCode');

    try {
      final response = await http.post(
        url,
        headers: {'origin': 'https://cemantix.certitudes.org'},
        body: {'word': word},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }
}
