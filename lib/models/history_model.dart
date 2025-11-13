import 'package:cemantix/models/word_model.dart';

class HistoryModel {
  final String _date;
  final List<WordModel> _words;

  String get date => _date;
  List<WordModel> get words => _words;

  HistoryModel({required String date, List<WordModel>? words})
    : _date = date,
      _words = words ?? [];

  void addWord(WordModel word) {
    words.add(word);
    words.sort((a, b) => b.temparature.compareTo(a.temparature));
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'words': words.map((w) => w.toJson()).toList(),
  };

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      date: json['date'],
      words: (json['words'] as List)
          .map((item) => WordModel.fromJson(item))
          .toList(),
    );
  }
}
