import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/currency.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';
import 'database.dart';

const List<String> apiKeys = [
  "coinranking4c11ba860e5e60cd651d33d572455c02d226f9c5fae2a0fc",
  "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  "coinranking07d435fd0b01815c688e99e21b5f63483f5bbc8a34ab5740",
];

Future<List<Crypto>> getListings({
  order = "marketCap",
  List<String>? ids,
  String? search,
  String orderDirection = "desc",
  int offset = 0,
  int limit = 50,
}) async {
  String currency = Database.getValue("settings", "currency");

  print(Database.getValue("settings", "currency"));
  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": await getCurrencyUuid(currency),
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

  http.StreamedResponse response = await request.send();

  var responseJson = json.decode(await response.stream.bytesToString());
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

Future<List<CoinPrice>> getPricesHistory(
    String coinId, String timePeriod) async {
  String currency = Database.getValue("settings", "currency");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": await getCurrencyUuid(currency),
    "timePeriod": timePeriod
  };

  Uri url = Uri.https(
      'api.coinranking.com', "/v2/coin/${coinId}/history", queryParams);
  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
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

Future<Crypto> getCoinData(String id) async {
  String currency = Database.getValue("settings", "currency");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": await getCurrencyUuid(currency),
  };

  Uri url = Uri.https('api.coinranking.com', "/v2/coin/$id", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
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

Future<List<Currency>> getAvailableCurrencies({
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

  http.StreamedResponse responseJson = await request.send();

  var response = jsonDecode(await responseJson.stream.bytesToString());
  var data = response["data"];
  List<Currency> currencies = [];
  for (var currency in data["currencies"]) {
    currencies.add(Currency(
      type: currency["type"],
      name: currency["name"],
      symbol: currency["symbol"],
      iconUrl: currency["iconUrl"],
      sign: currency["sign"],
    ));
  }

  return currencies;
}

Future<String> getCurrencyUuid(String symbol) async {
  Map<String, dynamic> queryParams = {
    "search": symbol,
    "limit": "1",
  };

  Uri url =
      Uri.https('api.coinranking.com', "/v2/reference-currencies", queryParams);

  http.Request request = http.Request("get", url);

  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var results = json.decode(await responseJson.stream.bytesToString());
  return results["data"]["currencies"][0]["uuid"];
}

String getApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(apiKeys.length)];
}
