import 'dart:convert';
import 'package:cemantix/const.dart';
import 'package:cemantix/models/history_model.dart';
import 'package:cemantix/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<HistoryModel?> getItemByDate(String dateIso) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(HISTORY_KEY);
    if (historyJson == null || historyJson.isEmpty) return null;

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      final List<Map<String, dynamic>> historyList =
          List<Map<String, dynamic>>.from(decoded);
      final found = historyList.firstWhere(
        (item) => item['date'] == dateIso,
        orElse: () => {},
      );
      if (found.isEmpty) return null;
      return HistoryModel.fromJson(Map<String, dynamic>.from(found));
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateItem(HistoryModel updatedItem) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(HISTORY_KEY);

    // If no stored history yet, create a new list containing the item.
    if (historyJson == null || historyJson.isEmpty) {
      final initial = [updatedItem.toJson()];
      await prefs.setString(HISTORY_KEY, jsonEncode(initial));
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      final List<Map<String, dynamic>> historyList =
          List<Map<String, dynamic>>.from(decoded);

      final index = historyList.indexWhere(
        (item) => item['date'] == updatedItem.date,
      );
      if (index != -1) {
        historyList[index] = updatedItem.toJson();
      } else {
        historyList.add(updatedItem.toJson());
      }
      await prefs.setString(HISTORY_KEY, jsonEncode(historyList));
    } catch (e) {
      await prefs.setString(HISTORY_KEY, jsonEncode([updatedItem.toJson()]));
    }
  }

  static Future<List<HistoryModel>> getHistoryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(HISTORY_KEY);

    if (historyJson == null || historyJson.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      List<HistoryModel> list = decoded
          .map((item) => HistoryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      String todaysDate = getTodaysDate();
      list = list.where((item) => item.date != todaysDate).toList();
      return list;
    } catch (e) {
      return [];
    }
  }
}
