import 'package:cryptotracker/screens/favorites.dart';
import 'package:cryptotracker/screens/portfolio_screen.dart';
import 'package:cryptotracker/screens/settings.dart';
import 'package:flutter/material.dart';

import 'screens/home.dart';

class PagesLayout extends StatefulWidget {
  final bool displayNavBar;
  final int? currentSection;

  const PagesLayout({
    super.key,
    this.displayNavBar = true,
    this.currentSection,
  });

  @override
  State<PagesLayout> createState() => _PagesLayoutState();
}

class _PagesLayoutState extends State<PagesLayout> {
  late int currentPageIndex;

  final List<Widget> pages = const [
    Home(),
    Favorites(),
    PortfolioScreen(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currentSection ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      bottomNavigationBar: widget.displayNavBar
          ? NavigationBar(
              selectedIndex: currentPageIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                NavigationDestination(
                    icon: Icon(Icons.star), label: "Favorites"),
                NavigationDestination(
                    icon: Icon(Icons.pie_chart), label: "Portfolio"),
                NavigationDestination(
                    icon: Icon(Icons.settings), label: "Settings"),
              ],
            )
          : null,
    );
  }
}
