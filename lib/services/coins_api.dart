import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/currency.dart';
import 'package:cryptotracker/models/news.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';
import 'settingsDB.dart';

const List<String> apiKeys = ["RCOsRbJcp62Ns6gkiqy4a3WGX7aJq9vzHaMIjiHp998="];

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
  http.Request request = http.Request("get", url);

  request.headers.addAll({"X-API-KEY": getApiKey()});
  http.StreamedResponse response;
  try {
    response = await request.send();
  } catch (e) {
    return null;
  }

  var responseJson = json.decode(await response.stream.bytesToString());
  if (response.statusCode != 200) {
    return null;
  }

  var listing = responseJson["result"];
  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["id"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: crypto["price"].toDouble(),
      logoUrl: crypto["icon"],
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
  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-API-KEY": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = json.decode(await responseJson.stream.bytesToString());

  if (responseJson.statusCode != 200) {
    return null;
  }

  var pricesHistoryData = response;

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
  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-API-KEY": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = json.decode(await responseJson.stream.bytesToString());
  if (responseJson.statusCode != 200) {
    return null;
  }
  var responseData = response;

  return Crypto(
    id: responseData["id"],
    name: responseData["name"],
    symbol: responseData["symbol"],
    logoUrl: responseData["icon"],
    price: responseData["price"].toDouble(),
    priceChangePercentageDay: (responseData["priceChange1d"] ?? 0).toDouble(),
    // description: responseData["description"],
    // categories: responseData["tags"].cast<String>(),
    website: responseData["websiteUrl"],
    // ath: double.tryParse(responseData["allTimeHigh"]["price"] ?? ""),
    // athDate: DateTime.fromMillisecondsSinceEpoch(
    //     (responseData["allTimeHigh"]["timestamp"] ?? 0) * 1000),
    marketCap: responseData["marketCap"].toDouble(),
    totalSupply: responseData["totalSupply"].toDouble(),
    circulatingSupply: responseData["availableSupply"].toDouble(),
    volume: responseData["volume"].toDouble(),
  );
}

Future<List<Currency>?> getAvailableCurrencies() async {
  Uri url = Uri.https('openapiv1.coinstats.app', "/fiats");
  print(url);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-API-KEY": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = jsonDecode(await responseJson.stream.bytesToString());
  if (responseJson.statusCode != 200) {
    return null;
  }

  var data = response;
  List<Currency> currencies = [];
  for (var currency in data) {
    currencies.add(Currency(
      name: currency["name"],
      symbol: currency["symbol"],
      iconUrl: currency["imageUrl"],
      rate: currency["rate"].toDouble(),
    ));
  }

  return currencies;
}

Future<List<News>?> getNews(bool type) async {
  Uri url = Uri.https('openapiv1.coinstats.app', "/news/type/$type");
  print(url);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-API-KEY": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = jsonDecode(await responseJson.stream.bytesToString());
  if (responseJson.statusCode != 200) {
    return null;
  }

  var data = response;

  List<News> newsList = [];
  for (var news in data) {
    newsList.add(News(
      title: news["title"],
      source: news["source"],
      imgUrl: news["imgUrl"],
      feedDate: DateTime.fromMillisecondsSinceEpoch(news["feedDate"]),
      url: news["link"],
      description: news["description"],
    ));
  }

  return newsList;
}

String getApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(apiKeys.length)];
}
