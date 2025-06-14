import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

String formatePrice(double? price, String symbol) {
  int priceLength = (price ?? 0.0).floor().toString().length;
  int priceTotalLength = 5;

  String formattedPrice;
  if ((price ?? 0.0) < (1 / pow(10, priceTotalLength - 1))) {
    formattedPrice =
        "${(price ?? 0).toStringAsFixed(8)} ${symbol.toUpperCase()}";
  } else {
    int decimalDigits =
        priceLength > priceTotalLength ? 0 : (priceTotalLength - priceLength);

    NumberFormat formatter = NumberFormat.currency(
        locale: "fr",
        symbol: symbol.toUpperCase(),
        decimalDigits: decimalDigits);

    formattedPrice = formatter.format(price ?? 0.0).replaceAll(",", ".");
  }

  return formattedPrice;
}

Widget getCoinLogoWidget(String logoUrl) {
  return Image.network(
    logoUrl,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    },
  );
}

Future<http.Response> httpGet(Uri url) async {
  Uri requestURl = Uri.parse(toProxyUrl(url.toString())!);

  var reponse = await http.get(requestURl);

  return reponse;
}

String? toProxyUrl(String? url) {
  if (url == null) {
    return null;
  }
  Uri resultURL = Uri.https("ctproxy.futureofthe.tech", "", {"url": url});
  return resultURL.toString();
}
