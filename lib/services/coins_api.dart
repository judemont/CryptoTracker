import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/currency.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';
import 'database.dart';

const List<String> apiKeys = [
  // "coinranking4c11ba860e5e60cd651d33d572455c02d226f9c5fae2a0fc",
  // "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  // "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  // "coinranking07d435fd0b01815c688e99e21b5f63483f5bbc8a34ab5740",
  // "coinranking0b154d4543ba0d09eac0048404b08be69aca18bc90116bf8",
  // "coinranking1a4fb2bff8b38ab670bc606a5b3316d558bd4fa651366747",
  // "coinrankingca05d3f372e62d80f679635853e5db9089ae28c6fd3e6660",
  "coinranking26f4beafffc148b6dbc4efd8afedee382bb42df290f32b03",
  "coinranking21a838917d0bf67e881b9b9b18a4259a518d22a33999b00e",
  "coinranking475fe18d831fede622a850e02e002ff36a15968ed882b1c7",
  "coinranking179e0cc0a98ed8bf3061a287a3818f6c94d97513b455b7d6",
  "coinranking40270d23867c8bda870f0610e75445bc43e81f72655b7c98",
  "coinrankingde2a6de705834797a3af7e5b15d2da70ede3c5974cf3613c",
  "coinranking855aca4a7bd7fdef982d9026c82979765cecf875ced7adba",
  "coinrankingffba8aa23e6d32339d885d02788e7a923a9699ec5bbb5673",
  "coinrankinge5a0741f62b20821b1ef32b707b3d191d189675096ada0fb",
];

Future<List<Crypto>?> getListings({
  order = "marketCap",
  List<String>? ids,
  String? search,
  String orderDirection = "desc",
  int offset = 0,
  int limit = 50,
}) async {
  String currency = Database.getValue("settings", "currencyId");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": currency,
    "orderBy": order,
    "limit": limit.toString(),
    "orderDirection": orderDirection,
    "offset": offset.toString()
  };

  if (ids != null) {
    queryParams["uuids"] = ids.join(",");
  }

  if (search != null) {
    queryParams["search"] = search;
  }

  Uri url = Uri.https('api.coinranking.com', "/v2/coins", queryParams);
  http.Request request = http.Request("get", url);

  print(url);
  request.headers.addAll({"x-access-token": getApiKey()});
  http.StreamedResponse response;
  try {
    response = await request.send();
  } catch (e) {
    return null;
  }

  var responseJson = json.decode(await response.stream.bytesToString());
  if (responseJson["status"] != "success") {
    return null;
  }

  var listing = responseJson["data"]["coins"];

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["uuid"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: double.tryParse(crypto["price"] ?? ""),
      logoUrl: crypto["iconUrl"],
      priceChangePercentageDay: double.tryParse(crypto["change"] ?? ""),
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>?> getPricesHistory(
    String coinId, String timePeriod) async {
  String currency = Database.getValue("settings", "currencyId");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": currency,
    "timePeriod": timePeriod
  };

  Uri url = Uri.https(
      'api.coinranking.com', "/v2/coin/$coinId/history", queryParams);
  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = json.decode(await responseJson.stream.bytesToString());

  if (response["status"] != "success") {
    return null;
  }

  var pricesHistoryData = response["data"]["history"];

  List<CoinPrice> pricesHistory = [];

  for (var data in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.fromMillisecondsSinceEpoch(data["timestamp"] * 1000),
      price: double.tryParse(data["price"] ?? ""),
    ));
  }

  return pricesHistory;
}

Future<Crypto?> getCoinData(String id) async {
  String currency = Database.getValue("settings", "currencyId");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": currency,
  };

  Uri url = Uri.https('api.coinranking.com', "/v2/coin/$id", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = json.decode(await responseJson.stream.bytesToString());
  if (response["status"] != "success") {
    return null;
  }
  var responseData = response["data"]["coin"];

  return Crypto(
    id: responseData["uuid"],
    name: responseData["name"],
    symbol: responseData["symbol"],
    price: double.tryParse(responseData["price"] ?? ""),
    logoUrl: responseData["iconUrl"],
    priceChangePercentageDay: double.tryParse(responseData["change"] ?? ""),
    description: responseData["description"],
    categories: responseData["tags"].cast<String>(),
    website: responseData["websiteUrl"],
    ath: double.tryParse(responseData["allTimeHigh"]["price"] ?? ""),
    athDate: DateTime.fromMillisecondsSinceEpoch(
        (responseData["allTimeHigh"]["timestamp"] ?? 0) * 1000),
    marketCap: double.tryParse(responseData["marketCap"] ?? ""),
    totalSupply: double.tryParse(
        responseData["supply"]["max"] ?? responseData["supply"]["total"] ?? ""),
    circulatingSupply:
        double.tryParse(responseData["supply"]["circulating"] ?? ""),
    volume: double.tryParse(responseData["24hVolume"] ?? ""),
  );
}

Future<List<Currency>?> getAvailableCurrencies({
  String? search,
  int offset = 0,
  int limit = 50,
}) async {
  Map<String, dynamic> queryParams = {
    "limit": limit.toString(),
    "offset": offset.toString()
  };

  if (search != null) {
    queryParams["search"] = search;
  }

  Uri url =
      Uri.https('api.coinranking.com', "/v2/reference-currencies", queryParams);
  print(url);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson;
  try {
    responseJson = await request.send();
  } catch (e) {
    print(e);
    return null;
  }

  var response = jsonDecode(await responseJson.stream.bytesToString());
  if (response["status"] != "success") {
    return null;
  }

  var data = response["data"];
  List<Currency> currencies = [];
  for (var currency in data["currencies"]) {
    currencies.add(Currency(
      id: currency["uuid"],
      type: currency["type"],
      name: currency["name"],
      symbol: currency["symbol"],
      iconUrl: currency["iconUrl"],
      sign: currency["sign"],
    ));
  }

  return currencies;
}

String getApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(apiKeys.length)];
}
