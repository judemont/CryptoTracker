import 'package:flutter/material.dart';

class PagesLayout extends StatefulWidget {
  final Widget child;

  const PagesLayout({
    super.key,
    required this.child,
  });

  @override
  State<PagesLayout> createState() => _PagesLayoutState();
}

class _PagesLayoutState extends State<PagesLayout> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
    );
  }
}
