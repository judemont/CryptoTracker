import 'package:intl/intl.dart';

String formatePrice(double? price, {String? symbol = "USD"}) {
  int priceLength = (price ?? 0.0).floor().toString().length;

  NumberFormat formatter = NumberFormat.currency(
      locale: "fr",
      symbol: symbol?.toUpperCase(),
      decimalDigits: priceLength > 5 ? 0 : (5 - priceLength));

  String formattedPrice = formatter.format(price ?? 0.0);

  return formattedPrice;
}
