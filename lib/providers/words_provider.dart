import 'package:cemantix/models/history_model.dart';
import 'package:cemantix/models/word_model.dart';
import 'package:cemantix/services/storage_service.dart';
import 'package:cemantix/utils/utils.dart';
import 'package:flutter/foundation.dart';

import 'package:timezone/data/latest.dart' as tz;

class WordsProvider extends ChangeNotifier {
  int _currentRank = 0;
  WordModel? _currentWord;
  HistoryModel? _wordHistory;
  bool _isLoading = true;
  String _todaysDate = '';
  int? _lastInsertedIndex;

  WordsProvider() {
    init();
  }

  bool get isLoading => _isLoading;
  int get currentRank => _currentRank;
  WordModel? get currentWord => _currentWord;
  HistoryModel? get wordHistory => _wordHistory;
  String get todaysDate => _todaysDate;
  int? get lastInsertedIndex => _lastInsertedIndex;

  Future<void> init() async {
    tz.initializeTimeZones();
    _todaysDate = getTodaysDate();
    _wordHistory =
        await StorageService.getItemByDate(_todaysDate) ??
        HistoryModel(date: _todaysDate, words: []);
    _isLoading = false;
    notifyListeners();
  }

  void clearLastInsertedIndex() {
    _lastInsertedIndex = null;
  }

  Future<void> addWord(
    String date,
    String word,
    double score,
    int rank,
    double progress,
  ) async {
    if (date != _todaysDate) {
      _todaysDate = getTodaysDate();
      _wordHistory =
          await StorageService.getItemByDate(_todaysDate) ??
          HistoryModel(date: _todaysDate, words: []);
    }

    final newWord = WordModel(
      word: word,
      temparature: score,
      progress: progress,
    );
    _wordHistory?.addWord(newWord);

    final index = _wordHistory?.words.indexWhere(
      (w) =>
          w.word.toLowerCase() == newWord.word.toLowerCase() &&
          w.temparature == newWord.temparature,
    );

    _lastInsertedIndex = index;

    await StorageService.updateItem(_wordHistory!);
    _currentWord = newWord;
    _currentRank = rank;
    notifyListeners();
  }
}
