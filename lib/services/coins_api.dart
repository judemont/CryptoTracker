import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

const List<String> apiKeys = [
  "CG-WLqjJpvFoq2XU2SXZEknL1aD",
  "CG-LjYqP1F8vpFF4SJyYxdVyDwZ",
  "CG-jwFmM1F8Zn6NRPMqsGMpQY2Y",
  "CG-LiRwwL2ZgQkaq9jJ5o5pGnKA",
];

Future<List<Crypto>> getListings({order = "market_cap_desk"}) async {
  Map<String, dynamic> queryParams = {
    "vs_currency": "usd",
    "order": order,
  };

  Uri url =
      Uri.https('api.coingecko.com', "/api/v3/coins/markets", queryParams);

  http.Request request = http.Request("get", url);

  request.headers.addAll({"x-cg-demo-api-key": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var listing = json.decode(await responseJson.stream.bytesToString());

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["id"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: crypto["current_price"]?.toDouble(),
      logoUrl: crypto["image"],
      priceChangePercentageDay: crypto["price_change_percentage_24h"],
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>> getPricesHistory(String coinId, int daysNum) async {
  Map<String, dynamic> queryParams = {
    "vs_currency": "usd",
    "days": daysNum.toString()
  };

  Uri url = Uri.https(
      'api.coingecko.com', "/api/v3/coins/$coinId/market_chart", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-cg-demo-api-key": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());

  var pricesHistoryData = response["prices"];

  List<CoinPrice> pricesHistory = [];

  for (var data in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.fromMillisecondsSinceEpoch(data[0]),
      price: data[1],
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
    price: response["market_data"]["current_price"]["usd"].toDouble(),
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
    ath: response["market_data"]["ath"]["usd"].toDouble(),
    athDate: DateTime.tryParse(response["market_data"]["ath_date"]["usd"]),
    marketCap: response["market_data"]["market_cap"]["usd"].toDouble(),
    marketCapRank: response["market_data"]["market_cap_rank"],
    dayHigh: response["market_data"]["high_24h"]["usd"].toDouble(),
    dayLow: response["market_data"]["low_24h"]["usd"].toDouble(),
    totalSupply: response["market_data"]["total_supply"].toDouble(),
    circulatingSupply: response["market_data"]["circulating_supply"].toDouble(),
    volume: response["market_data"]["total_volume"]["usd"].toDouble(),
  );
}

String getApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(apiKeys.length)];
}
