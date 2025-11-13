class WordModel {
  final String _word;
  final double _temparature;
  final double _progress;

  String get word => _word;
  double get temparature => _temparature;
  double get progress => _progress;

  WordModel({
    required String word,
    required double temparature,
    required double progress,
  }) : _word = word,
       _temparature = temparature,
       _progress = progress;

  Map<String, dynamic> toJson() => {
    'word': word.toLowerCase(),
    'temparature': temparature,
    'progress': progress,
  };

  factory WordModel.fromJson(Map<String, dynamic> json) {
    final temp = json['temparature'];
    double parsedValue = 0.0;
    if (temp is String) {
      parsedValue = double.tryParse(temp) ?? 0.0;
    } else if (temp is num) {
      parsedValue = temp.toDouble();
    }

    final prog = json['progress'];
    double parsedValue1 = 0.0;
    if (prog is String) {
      parsedValue1 = double.tryParse(prog) ?? 0.0;
    } else if (prog is num) {
      parsedValue1 = prog.toDouble();
    }
    return WordModel(
      word: json['word'],
      temparature: parsedValue,
      progress: parsedValue1,
    );
  }
}
