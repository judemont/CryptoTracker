import 'package:flutter/material.dart';

import '../models/crypto.dart';

class DetailedView extends StatefulWidget {
  final Crypto crypto;
  const DetailedView({super.key, required this.crypto});

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Container(
          margin: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.crypto.name ?? "",
                style: const TextStyle(fontSize: 25),
              )
            ],
          )),
    );
  }
}
