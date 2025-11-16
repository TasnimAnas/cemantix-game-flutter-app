import 'package:cemantix/models/history_model.dart';
import 'package:cemantix/widgets/progress_bar.dart';
import 'package:cemantix/widgets/word_sky_background.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/utils.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryModel history;

  const HistoryDetailPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final words = history.words;
    return Container(
      decoration: kScaffoldDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(history.date), elevation: 0),
        body: Stack(
          children: [
            Positioned.fill(child: WordSkyBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Card(
                      color: kCard.withOpacity(0.6),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    history.date,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${words.length} guesses',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Max',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  words.isNotEmpty
                                      ? formatTemperatureWithEmoji(
                                          words.first.temparature,
                                        )
                                      : '-',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: words.length,
                        itemBuilder: (context, i) {
                          final w = words[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            color: kCard.withOpacity(0.6),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ListTile(
                                title: Text(
                                  '${i + 1}. ${w.word}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                trailing: Text(
                                  formatTemperatureWithEmoji(w.temparature),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                subtitle: w.progress != 0
                                    ? ProgressBar(progress: w.progress)
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
