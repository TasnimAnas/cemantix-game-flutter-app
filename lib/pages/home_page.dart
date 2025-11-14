import 'package:cemantix/models/word_model.dart';
import 'package:cemantix/widgets/cemantix_game_screen.dart';
import 'package:cemantix/providers/words_provider.dart';
import 'package:cemantix/widgets/progress_bar.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _listController = ScrollController();
  static const double _estimatedItemExtent = 72.0;
  late List<WordModel> _items;
  WordsProvider? _provider;
  final Set<int> _recentInserted = {};
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _items = [];
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = Provider.of<WordsProvider>(context);
    if (_provider == null) {
      _provider = p;
      final initial = p.wordHistory?.words ?? [];
      _items = List<WordModel>.from(initial);
      p.addListener(_onProviderChange);
    } else if (_provider != p) {
      _provider?.removeListener(_onProviderChange);
      _provider = p;
      _provider?.addListener(_onProviderChange);
      _items = List<WordModel>.from(_provider?.wordHistory?.words ?? []);
    }
  }

  void _onProviderChange() async {
    final p = _provider;
    if (p == null) return;

    final idx = p.lastInsertedIndex;
    final newWord = p.currentWord;
    if (idx != null && newWord != null) {
      final insertIndex = idx.clamp(0, (_items.length));

      try {
        final targetOffset = (insertIndex * _estimatedItemExtent).clamp(
          0.0,
          _listController.hasClients
              ? _listController.position.maxScrollExtent
              : 0.0,
        );
        if (_listController.hasClients) {
          await _listController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
        }
      } catch (_) {
        print('Scroll animation failed');
      }

      setState(() {
        _items.insert(insertIndex, newWord);
        _recentInserted.add(insertIndex);
      });

      _listKey.currentState?.insertItem(
        insertIndex,
        duration: const Duration(milliseconds: 450),
      );

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() => _recentInserted.remove(insertIndex));
        }
      });

      p.clearLastInsertedIndex();
      return;
    }

    // If provider updated for other reasons (like initial load), refresh list.
    final updated = p.wordHistory?.words ?? [];

    if (!_listEquals(updated, _items)) {
      // If local list is empty but provider has items (initial load), populate AnimatedList with insert animations.
      if (_items.isEmpty && updated.isNotEmpty) {
        // Insert items and schedule AnimatedList insertions after frame so the list is mounted.
        for (var i = 0; i < updated.length; i++) {
          _items.insert(i, updated[i]);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _listKey.currentState?.insertItem(
              i,
              duration: const Duration(milliseconds: 200),
            );
          });
        }
        // Ensure the widget updates to reflect the new internal list.
        setState(() {});
      } else {
        // For other updates (e.g., external replacement), perform a simple replace.
        setState(() {
          _items = List<WordModel>.from(updated);
        });
      }
    }
  }

  bool _listEquals(List<WordModel> a, List<WordModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].word != b[i].word || a[i].temparature != b[i].temparature)
        return false;
    }
    return true;
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildLatestCard(WordsProvider p) {
    final current = p.currentWord;
    if (current == null) {
      return Card(
        color: kCard,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Take a new guess!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    if (current.temparature >= 100 || current.progress >= 1000) {
      _confettiController?.play();
    }

    return Card(
      color: kCard,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.word,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      if (current.progress != 0)
                        ProgressBar(progress: current.progress),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text(
                      'Rank: ${p.currentRank}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatTemperatureWithEmoji(current.temparature),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.directional,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.red,
                  Colors.cyan,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final item = _items[index];
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    final isNew = _recentInserted.contains(index);

    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 0 : 12),
      child: SizeTransition(
        sizeFactor: fade,
        axisAlignment: 0.0,
        child: FadeTransition(
          opacity: fade,
          child: AnimatedPhysicalModel(
            duration: kAnimationDuration,
            curve: kAnimationCurve,
            shape: BoxShape.rectangle,
            elevation: isNew ? (kCardElevation + 6.0) : kCardElevation,
            color: kCard,
            shadowColor: Theme.of(context).shadowColor,
            borderRadius: kCardRadius,
            child: Card(
              elevation: 0,
              color: kCard,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  '${index + 1}. ${item.word}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  formatTemperatureWithEmoji(item.temparature),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: item.progress != 0
                    ? ProgressBar(progress: item.progress)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordsProvider>(
      builder: (context, p, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CemantixGameScreen(),
                AnimatedSwitcher(
                  duration:
                      kAnimationDuration + const Duration(milliseconds: 400),
                  switchInCurve: kAnimationCurve,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, anim) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, -0.08),
                        end: Offset.zero,
                      ).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(p.currentWord?.word ?? 'empty'),
                    child: _buildLatestCard(p),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Today\'s guesses',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedList(
                      padding: EdgeInsets.all(10),
                      key: _listKey,
                      controller: _listController,
                      initialItemCount: _items.length,
                      itemBuilder: _buildListItem,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
