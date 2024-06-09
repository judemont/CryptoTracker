import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';
import 'database.dart';

const List<String> apiKeys = [
  "coinranking4c11ba860e5e60cd651d33d572455c02d226f9c5fae2a0fc",
  "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
];

const coinrankingApiKeys = [
  "coinranking4c11ba860e5e60cd651d33d572455c02d226f9c5fae2a0fc",
  "coinrankingbf6652d36b448473ae1fba8a722ae1833b23b80616331bb0",
  "coinranking07d435fd0b01815c688e99e21b5f63483f5bbc8a34ab5740"
];

Future<List<Crypto>> getListings(
    {order = "marketCap", List<String>? ids}) async {
  String currency = Database.getValue("settings", "currency");

  print(Database.getValue("settings", "currency"));
  Map<String, dynamic> queryParams = {
    "referenceCurrencyUuid": await getCurrencyUuid(currency),
    "orderBy": order,
  };

  if (ids != null) {
    queryParams["symbols"] = ids.join(",");
  }

  Uri url = Uri.https('api.coinranking.com', "/v2/coins", queryParams);
  print(url);
  http.Request request = http.Request("get", url);

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
      price: double.tryParse(crypto["price"]),
      logoUrl: crypto["iconUrl"],
      priceChangePercentageDay: double.tryParse(crypto["change"]),
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
      price: data["price"],
    ));
  }

  return pricesHistory;
}

Future<List<Crypto>> search(String query) async {
  Map<String, dynamic> queryParams = {
    "query": query,
  };

  Uri url = Uri.https('api.coingecko.com', "/api/v3/search", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-cg-demo-api-key": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
  List elements = response["coins"];

  List<Crypto> results = [];

  for (var i = 0; i < elements.length; i++) {
    results.add(Crypto(
      id: elements[i]["id"],
      name: elements[i]["name"],
      symbol: elements[i]["symbol"],
      logoUrl: elements[i]["thumb"],
    ));
  }
  return results;
}

Future<Crypto> getCoinData(String id) async {
  String currency = Database.getValue("settings", "currency");

  Map<String, dynamic> queryParams = {};

  Uri url = Uri.https('api.coingecko.com', "/api/v3/coins/$id", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-cg-demo-api-key": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
  // print(response["market_data"]["price_change_1y"]);

  return Crypto(
    id: response["id"],
    name: response["name"],
    symbol: response["symbol"],
    price: response["market_data"]["current_price"][currency].toDouble(),
    logoUrl: response["image"]["small"],
    priceChangePercentageDay: response["market_data"]
        ["price_change_percentage_24h"],
    priceChangePercentageWeek: response["market_data"]
        ["price_change_percentage_7d"],
    priceChangePercentageMonth: response["market_data"]
        ["price_change_percentage_30d"],
    priceChangePercentageYear: response["market_data"]
        ["price_change_percentage_1y"],
    description: response["description"]["en"],
    categories: response["categories"].cast<String>(),
    website: response["links"]["homepage"]?[0],
    ath: response["market_data"]["ath"][currency]?.toDouble(),
    athDate: DateTime.tryParse(response["market_data"]["ath_date"][currency]),
    marketCap: response["market_data"]["market_cap"][currency]?.toDouble(),
    marketCapRank: response["market_data"]["market_cap_rank"],
    dayHigh: response["market_data"]["high_24h"][currency]?.toDouble(),
    dayLow: response["market_data"]["low_24h"][currency]?.toDouble(),
    totalSupply: response["market_data"]["total_supply"]?.toDouble(),
    circulatingSupply:
        response["market_data"]["circulating_supply"]?.toDouble(),
    volume: response["market_data"]["total_volume"][currency]?.toDouble(),
  );
}

Future<List<String>> getAvailableCurrencies() async {
  Uri url =
      Uri.https('api.coingecko.com', "/api/v3/simple/supported_vs_currencies");

  var response = await http.get(url);
  List currencies = jsonDecode(response.body);
  return currencies.cast<String>();
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

String getCoinRankingApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(coinrankingApiKeys.length)];
}
