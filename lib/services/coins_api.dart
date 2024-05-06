import 'dart:convert';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

const String apiKey =
    "a599804834d4eb69c45e08f8dd3e26a0a82483c6ad187906978ce572796e9464";

Future<List<Crypto>> getListings() async {
  Map<String, dynamic> queryParams = {
    "limit": 100.toString(),
    "tsym": "USD",
  };

  Uri url = Uri.https(
      'min-api.cryptocompare.com', "/data/top/mktcapfull", queryParams);

  http.Request request = http.Request("get", url);

  request.headers.addAll({"authorization": "Apikey $apiKey"});

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

// Future<double> getPrice(String? symbol, {bool? localTest}) async {
//   const testData = '''{'USD':3151.9}''';

//   Map<String, dynamic> queryParams = {
//     "fsym": symbol,
//     "tsyms": "USD",
//   };

//   Uri url = Uri.https('min-api.cryptocompare.com', "/data/pice", queryParams);

//   http.Request request = http.Request("get", url);

//   request.headers.addAll({"authorization": "Apikey $apiKey"});

//   http.StreamedResponse responseJson = await request.send();

//   var response;
//   if (!(localTest ?? false)) {
//     response = json.decode(await responseJson.stream.bytesToString());
//   } else {
//     print("USING TEST DATA");
//     response = json.decode(testData);
//   }
//   double price = response["USD"];

//   return price;
// }

Future<List<CoinPrice>> getPricesHistory(String symbol, int limit,
    {String interval = "hour"}) async {
  Map<String, dynamic> queryParams = {
    "fsym": symbol,
    'tsym': "USD",
    'limit': limit.toString(),
  };

  Uri url = Uri.https(
      'min-api.cryptocompare.com', "/data/v2/histo$interval", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"authorization": "Apikey $apiKey"});

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
