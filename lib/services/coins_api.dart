import 'dart:convert';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/currency.dart';
import 'package:cryptotracker/utils.dart';

import '../models/crypto.dart';
import 'settingsDB.dart';

Future<List<Crypto>?> getListings({
  order = "marketCap",
  String? search,
  String orderDirection = "desc",
  int page = 1,
  int limit = 50,
}) async {
  String currency = SettingsDb.getValue("settings", "currency"); // TODO

  Map<String, dynamic> queryParams = {
    "currency": currency,
    "sortBy": order,
    "limit": limit.toString(),
    "sortDir": orderDirection,
    "page": page.toString()
  };

  if (search != null) {
    queryParams["name"] = search;
  }

  Uri url = Uri.https('openapiv1.coinstats.app', "/coins", queryParams);
  print(url);

  var response = await httpGet(url);

  if (response.statusCode != 200) {
    return null;
  }

  var responseJson = json.decode(response.body);
  var listing = responseJson["result"];
  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["id"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: crypto["price"].toDouble(),
      logoUrl: toProxyUrl(crypto["icon"]),
      priceChangePercentageDay: (crypto["priceChange1d"] ?? 0).toDouble(),
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>?> getPricesHistory(
    String coin, String timePeriod) async {
  double currencyRate =
      SettingsDb.getValue("settings", "currencyRate").toDouble();

  Map<String, dynamic> queryParams = {"period": timePeriod};

  Uri url =
      Uri.https('openapiv1.coinstats.app', "/coins/$coin/charts", queryParams);

  var response = await httpGet(url);

  if (response.statusCode != 200) {
    return null;
  }

  var pricesHistoryData = json.decode(response.body);

  List<CoinPrice> pricesHistory = [];

  for (var data in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.fromMillisecondsSinceEpoch(data[0] * 1000),
      price: data[1].toDouble() * currencyRate,
    ));
  }

  return pricesHistory;
}

Future<Crypto?> getCoinData(String coin) async {
  String currency = SettingsDb.getValue("settings", "currency"); // TODO

  Map<String, dynamic> queryParams = {
    "currency": currency,
  };

  Uri url = Uri.https('openapiv1.coinstats.app', "/coins/$coin", queryParams);

  var response = await httpGet(url);

  if (response.statusCode != 200) {
    return null;
  }

  var responseData = json.decode(response.body);

  return Crypto(
    id: responseData["id"],
    name: responseData["name"],
    symbol: responseData["symbol"],
    logoUrl: toProxyUrl(responseData["icon"]),
    price: responseData["price"].toDouble(),
    priceChangePercentageDay: (responseData["priceChange1d"] ?? 0).toDouble(),
    website: responseData["websiteUrl"],
    marketCap: responseData["marketCap"].toDouble(),
    totalSupply: responseData["totalSupply"].toDouble(),
    circulatingSupply: responseData["availableSupply"].toDouble(),
    volume: responseData["volume"].toDouble(),
  );
}

Future<List<Currency>?> getAvailableCurrencies() async {
  Uri url = Uri.https('openapiv1.coinstats.app', "/fiats");
  print(url);

  var response = await httpGet(url);

  if (response.statusCode != 200) {
    return null;
  }

  var data = jsonDecode(response.body);
  List<Currency> currencies = [];
  for (var currency in data) {
    currencies.add(Currency(
      name: currency["name"],
      symbol: currency["symbol"],
      iconUrl: toProxyUrl(currency["imageUrl"]),
      rate: currency["rate"].toDouble(),
    ));
  }

  return currencies;
}

