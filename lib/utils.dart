import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

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

    formattedPrice = formatter.format(price ?? 0.0);
  }

  return formattedPrice;
}

Widget getCoinLogoWidget(String logoUrl) {
  if (logoUrl.contains(".svg")) {
    return SvgPicture.network(
      logoUrl,
    );
  } else {
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
}
