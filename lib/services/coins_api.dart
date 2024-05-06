import 'dart:convert';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

// const String apiKey = "";

Future<List<Crypto>> getListings() async {
  Map<String, dynamic> queryParams = {
    "limit": 100.toString(),
    "tsym": "USD",
  };

  Uri url = Uri.https(
      'min-api.cryptocompare.com', "/data/top/mktcapfull", queryParams);

  http.Request request = http.Request("get", url);

  // request.headers.addAll({"authorization": "Apikey $apiKey"});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());

  var listing = response['Data'];

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    var infos = crypto["CoinInfo"];
    var name = infos['FullName'];
    var symbol = infos['Internal'];
    var price = crypto["RAW"]?["USD"]["PRICE"];
    var logoUrl = "https://cryptocompare.com${infos["ImageUrl"]}";

    cryptoList.add(Crypto(
      name: name,
      symbol: symbol,
      price: price,
      logoUrl: logoUrl,
    ));
  }

  return cryptoList;
}

Future<List<CoinPrice>> getPricesHistory(String symbol, int limit,
    {String unit = "hour", int interval = 1}) async {
  Map<String, dynamic> queryParams = {
    "fsym": symbol,
    'tsym': "USD",
    'aggregate': interval.toString(),
    'limit': limit.toString(),
  };

  Uri url = Uri.https(
      'min-api.cryptocompare.com', "/data/v2/histo$unit", queryParams);

  http.Request request = http.Request("get", url);
  // request.headers.addAll({"authorization": "Apikey $apiKey"});

  http.StreamedResponse responseJson = await request.send();

  var response = json.decode(await responseJson.stream.bytesToString());
  List pricesHistoryData = response['Data']["Data"];

  List<CoinPrice> pricesHistory = [];

  for (var data in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.fromMillisecondsSinceEpoch(data["time"] * 1000),
      price: (data["high"] + data["low"]) / 2,
    ));
  }

  return pricesHistory;
}

// void main() {
//   getListing();
// }
