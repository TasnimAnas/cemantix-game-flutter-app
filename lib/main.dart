import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/words_provider.dart';
import 'theme.dart';
import 'pages/home_page.dart';
import 'pages/history_page.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WordsProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cemantix',
      theme: appTheme(),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [HomePage(), HistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kScaffoldDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _pages[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 5, 7, 11).withOpacity(0.6),
          currentIndex: _currentIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: kTextHint,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}
