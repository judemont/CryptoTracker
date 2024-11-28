import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/currency.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';
import 'database.dart';

const List<String> apiKeys = ["RCOsRbJcp62Ns6gkiqy4a3WGX7aJq9vzHaMIjiHp998="];

Future<List<Crypto>?> getListings({
  order = "marketCap",
  String? search,
  String orderDirection = "desc",
  int page = 0,
  int limit = 50,
}) async {
  String currency = "USD"; // TODO

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
  http.Request request = http.Request("get", url);

  print(url);
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
    String coinId, String timePeriod) async {
  String currency = Database.getValue("settings", "currencyId");

  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": currency,
    "timePeriod": timePeriod
  };

  Uri url =
      Uri.https('api.coinranking.com', "/v2/coin/$coinId/history", queryParams);
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
