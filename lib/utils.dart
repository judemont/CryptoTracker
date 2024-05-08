import 'dart:math';

import 'package:intl/intl.dart';

String formatePrice(double? price, {String? symbol = "USD"}) {
  int priceLength = (price ?? 0.0).floor().toString().length;
  int priceTotalLength = 5;

  String formattedPrice;

  if ((price ?? 0.0) < (1 / pow(10, priceTotalLength - 1))) {
    formattedPrice = (price ?? 0).toStringAsFixed(8);
  } else {
    int decimalDigits =
        priceLength > priceTotalLength ? 0 : (priceTotalLength - priceLength);

    NumberFormat formatter = NumberFormat.currency(
        locale: "fr",
        symbol: symbol?.toUpperCase(),
        decimalDigits: decimalDigits);

    formattedPrice = formatter.format(price ?? 0.0);
  }

  return formattedPrice;
}
