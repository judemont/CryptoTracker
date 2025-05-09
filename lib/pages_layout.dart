import 'package:cryptotracker/screens/favorites.dart';
import 'package:cryptotracker/screens/portfolio.dart';
import 'package:cryptotracker/screens/settings.dart';
import 'package:flutter/material.dart';

import 'screens/home.dart';

class PagesLayout extends StatefulWidget {
  final Widget child;
  final bool displayNavBar;
  final int? currentSection;

  const PagesLayout({
    super.key,
    required this.child,
    this.displayNavBar = true,
    this.currentSection,
  });

  @override
  State<PagesLayout> createState() => _PagesLayoutState();
}

class _PagesLayoutState extends State<PagesLayout> {
  late int currentPageIndex;
  late Widget currentChild;
  List<Widget> pages = [
    const Home(),
    const Favorites(),
    const Portfolio(),
    const Settings(),
  ];

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currentSection ?? 0;
    currentChild = widget.child;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: currentChild,
        bottomNavigationBar: widget.displayNavBar
            ? NavigationBar(
                selectedIndex: currentPageIndex,
                onDestinationSelected: (index) => setState(() {
                  currentPageIndex = index;
                  currentChild = pages[currentPageIndex];
                }),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                  NavigationDestination(
                      icon: Icon(Icons.star), label: "Favorites"),
                  NavigationDestination(
                      icon: Icon(Icons.pie_chart), label: "Portfolio"),
                  NavigationDestination(
                      icon: Icon(Icons.settings), label: "Settings")
                ],
              )
            : null);
  }
}
