import 'dart:convert';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

const String apiKey = "CG-WLqjJpvFoq2XU2SXZEknL1aD";

Future<List<Crypto>> getListings() async {
  Map<String, dynamic> queryParams = {
    "vs_currency": "usd",
    "order": "market_cap_desk",
  };

  Uri url =
      Uri.https('api.coingecko.com', "/api/v3/coins/markets", queryParams);

  http.Request request = http.Request("get", url);

  request.headers.addAll({"x-cg-demo-api-key": apiKey});

  http.StreamedResponse responseJson = await request.send();

  var listing = json.decode(await responseJson.stream.bytesToString());

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    cryptoList.add(Crypto(
      id: crypto["id"],
      name: crypto["name"],
      symbol: crypto["symbol"],
      price: crypto["current_price"].toDouble(),
      logoUrl: crypto["image"],
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>> getPricesHistory(
  String coinId,
  int daysNum,
) async {
  Map<String, dynamic> queryParams = {
    "vs_currency": "usd",
    "days": daysNum.toString()
  };

  Uri url = Uri.https(
      'api.coingecko.com', "/api/v3/coins/$coinId/market_chart", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-cg-demo-api-key": apiKey});

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

// Future getPrices(List<String> symbols, {bool? localTest}) async {
//   Map<String, dynamic> queryParams = {
//     "fsyms": symbols.join(","),
//     "tsyms": "USD",
//   };

//   Uri url =
//       Uri.https('min-api.cryptocompare.com', "/data/pricemulti", queryParams);
//   print(url.toString());
//   http.Request request = http.Request("get", url);

//   http.StreamedResponse responseJson = await request.send();

//   var response = json.decode(await responseJson.stream.bytesToString());
//   return response;
// }

Future<List<Crypto>> search(String query) async {
  Map<String, dynamic> queryParams = {
    "query": query,
  };

  Uri url = Uri.https('api.coingecko.com', "/api/v3/search", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"x-cg-demo-api-key": apiKey});

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
