import 'package:cemantix/services/api_service.dart';
import 'package:cemantix/utils/utils.dart';
import 'package:cemantix/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/words_provider.dart';
import '../theme.dart';

class CemantixGameScreen extends StatefulWidget {
  const CemantixGameScreen({super.key});

  @override
  State<CemantixGameScreen> createState() => _CemantixGameScreenState();
}

class _CemantixGameScreenState extends State<CemantixGameScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _submitGuess(BuildContext context) async {
    final guess = _controller.text.toLowerCase().trim();

    if (guess.isEmpty) return;
    if (Provider.of<WordsProvider>(context, listen: false).wordHistory!.words
        .any((w) => w.word.toLowerCase() == guess.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already guessed "$guess".')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> resp = await ApiService.sendWord(guess);
      if (resp['e'] != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$guess is not a valid word.')));
      } else if (resp.containsKey('s') && resp.containsKey('v')) {
        double score = resp['s'].toDouble() * 100;
        int rank = resp['v'];
        double progress = resp['p']?.toDouble() ?? 0.0;
        Provider.of<WordsProvider>(
          context,
          listen: false,
        ).addWord(getTodaysDate(), guess, score, rank, progress);
      }
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error. Check your connection.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: kAnimationDuration,
                opacity: _isLoading ? 0.6 : 1.0,
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _submitGuess(context),
                  decoration: InputDecoration(
                    hintText: 'Enter the word...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: kTextHint),
                    filled: true,
                    fillColor: kCard,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedSwitcher(
              duration: kAnimationDuration,
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _isLoading
                  ? SizedBox(
                      key: ValueKey('loading'),
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            kTextPrimary,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      key: ValueKey('send'),
                      width: 40,
                      height: 40,
                      child: GradientButton(
                        onPressed: () => _submitGuess(context),
                        borderRadius: 999,
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.send, color: kTextPrimary),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
