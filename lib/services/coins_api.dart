import 'dart:convert';
import 'dart:math';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

const List<String> apiKeys = [
  "coinranking4c11ba860e5e60cd651d33d572455c02d226f9c5fae2a0fc"
];

const apiBaseUrl = "api.coinranking.com";

Future<List<Crypto>> getListings(
    {String order = "marketCap",
    String orderDirection = "desc",
    String? search,
    int limit = 100}) async {
  Map<String, dynamic> queryParams = {
    "vs_currency": "usd",
    "orderBy": order,
  };

  if (search != null) {
    queryParams["search"] = search;
  }

  Uri url = Uri.https(apiBaseUrl, "/v2/coins", queryParams);

  http.Request request = http.Request("get", url);

  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
  var listing = response["data"]["coins"];

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["uuid"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: double.tryParse(crypto["price"]),
      logoUrl: Uri.tryParse(crypto["iconUrl"]),
      priceChangePercentageDay: double.tryParse(crypto["change"]),
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>> getPricesHistory(
    String coinId, String timePeriod) async {
  Map<String, dynamic> queryParams = {
    "timePeriod": timePeriod,
  };

  Uri url = Uri.https(apiBaseUrl, "/v2/coin/$coinId/history", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-access-token": getApiKey()});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());

  var pricesHistoryData = response["data"]["history"];

  List<CoinPrice> pricesHistory = [];

  for (var data in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.fromMillisecondsSinceEpoch(data["timestamp"]),
      price: double.tryParse(data["price"]),
    ));
  }

  return pricesHistory;
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
    ath: response["market_data"]["ath"]["usd"]?.toDouble(),
    athDate: DateTime.tryParse(response["market_data"]["ath_date"]["usd"]),
    marketCap: response["market_data"]["market_cap"]["usd"]?.toDouble(),
    marketCapRank: response["market_data"]["market_cap_rank"],
    dayHigh: response["market_data"]["high_24h"]["usd"]?.toDouble(),
    dayLow: response["market_data"]["low_24h"]["usd"]?.toDouble(),
    totalSupply: response["market_data"]["total_supply"]?.toDouble(),
    circulatingSupply:
        response["market_data"]["circulating_supply"]?.toDouble(),
    volume: response["market_data"]["total_volume"]["usd"]?.toDouble(),
  );
}

String getApiKey() {
  var random = Random();
  return apiKeys[random.nextInt(apiKeys.length)];
}
