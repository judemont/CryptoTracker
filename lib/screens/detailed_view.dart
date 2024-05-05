import 'package:flutter/material.dart';

import '../models/coin_price.dart';
import '../models/crypto.dart';
import '../services/coins_api.dart';

class DetailedView extends StatefulWidget {
  final Crypto crypto;
  const DetailedView({super.key, required this.crypto});

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  List<CoinPrice> pricesHistory = [];

  @override
  void initState() {
    loadPriceHistory();
    super.initState();
  }

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
              Row(
                children: [
                  Image.network(
                    widget.crypto.logoUrl ?? "",
                    width: 30.0,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.crypto.name ?? "",
                    style: const TextStyle(fontSize: 25),
                  )
                ],
              )
            ],
          )),
    );
  }

  Future<void> loadPriceHistory() async {
    getPricesHistory(widget.crypto.symbol).then((values) {
      setState(() {
        pricesHistory = values;
      });
      print(pricesHistory);
    });
  }
}
