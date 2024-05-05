import 'dart:convert';

import 'package:cryptotracker/models/coin_price.dart';
import 'package:http/http.dart' as http;

import '../models/crypto.dart';

const String apiKey = "bfb0b1ea-f762-4c51-981a-bee86518067a";

Future<List<Crypto>> getListings({bool? localTest}) async {
  const testData =
      '''{"data":[{"id":1,"name":"Bitcoin","symbol":"BTC","slug":"bitcoin","cmc_rank":5,"num_market_pairs":500,"circulating_supply":16950100,"total_supply":16950100,"max_supply":21000000,"infinite_supply":false,"last_updated":"2018-06-02T22:51:28.209Z","date_added":"2013-04-28T00:00:00.000Z","tags":["mineable"],"platform":null,"self_reported_circulating_supply":null,"self_reported_market_cap":null,"quote":{"USD":{"price":9283.92,"volume_24h":7155680000,"volume_change_24h":-0.152774,"percent_change_1h":-0.152774,"percent_change_24h":0.518894,"percent_change_7d":0.986573,"market_cap":852164659250.2758,"market_cap_dominance":51,"fully_diluted_market_cap":952835089431.14,"last_updated":"2018-08-09T22:53:32.000Z"},"BTC":{"price":1,"volume_24h":772012,"volume_change_24h":0,"percent_change_1h":0,"percent_change_24h":0,"percent_change_7d":0,"market_cap":17024600,"market_cap_dominance":12,"fully_diluted_market_cap":952835089431.14,"last_updated":"2018-08-09T22:53:32.000Z"}}},{"id":1027,"name":"Ethereum","symbol":"ETH","slug":"ethereum","num_market_pairs":6360,"circulating_supply":16950100,"total_supply":16950100,"max_supply":21000000,"infinite_supply":false,"last_updated":"2018-06-02T22:51:28.209Z","date_added":"2013-04-28T00:00:00.000Z","tags":["mineable"],"platform":null,"quote":{"USD":{"price":1283.92,"volume_24h":7155680000,"volume_change_24h":-0.152774,"percent_change_1h":-0.152774,"percent_change_24h":0.518894,"percent_change_7d":0.986573,"market_cap":158055024432,"market_cap_dominance":51,"fully_diluted_market_cap":952835089431.14,"last_updated":"2018-08-09T22:53:32.000Z"},"ETH":{"price":1,"volume_24h":772012,"volume_change_24h":-0.152774,"percent_change_1h":0,"percent_change_24h":0,"percent_change_7d":0,"market_cap":17024600,"market_cap_dominance":12,"fully_diluted_market_cap":952835089431.14,"last_updated":"2018-08-09T22:53:32.000Z"}}}],"status":{"timestamp":"2018-06-02T22:51:28.209Z","error_code":0,"error_message":"","elapsed":10,"credit_count":1}}''';

  Uri url = Uri.parse(
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest');

  http.Request request = http.Request("get", url);

  request.headers.addAll({"X-CMC_PRO_API_KEY": apiKey});

  http.StreamedResponse responseJson = await request.send();

  var response;
  if (!(localTest ?? false)) {
    response = json.decode(await responseJson.stream.bytesToString());
  } else {
    print("USING TEST DATA");
    response = json.decode(testData);
  }

  var listing = response['data'];

  Map metadatas = await getMetadata(listing.map((e) => e["symbol"]).toList(),
      localTest: localTest);

  List<Crypto> cryptoList = [];
  for (var crypto in listing) {
    var id = crypto['id'];
    var name = crypto['name'];
    var symbol = crypto['symbol'];
    var price = crypto["quote"]["USD"]["price"];
    var metadata = metadatas["data"][symbol]?[0];
    var website = metadata?["urls"]?["website"]?.isNotEmpty
        ? metadata?["urls"]?["website"][0]
        : null;
    var logoUrl = metadata?["logo"];
    var description = metadata?["description"];

    cryptoList.add(Crypto(
      id: id,
      name: name,
      symbol: symbol,
      price: price,
      website: website,
      logoUrl: logoUrl,
      description: description,
    ));
  }

  return cryptoList;
}

Future<Map> getMetadata(List ids, {bool? localTest}) async {
  const testData =
      '''{"data":{"1":{"urls":{"website":["https://bitcoin.org/"],"technical_doc":["https://bitcoin.org/bitcoin.pdf"],"twitter":[],"reddit":["https://reddit.com/r/bitcoin"],"message_board":["https://bitcointalk.org"],"announcement":[],"chat":[],"explorer":["https://blockchain.coinmarketcap.com/chain/bitcoin","https://blockchain.info/","https://live.blockcypher.com/btc/"],"source_code":["https://github.com/bitcoin/"]},"logo":"https://s2.coinmarketcap.com/static/img/coins/64x64/1.png","id":1,"name":"Bitcoin","symbol":"BTC","slug":"bitcoin","description":"BTC description","date_added":"2013-04-28T00:00:00.000Z","date_launched":"2013-04-28T00:00:00.000Z","tags":["mineable"],"platform":null,"category":"coin"},"1027":{"urls":{"website":["https://www.ethereum.org/"],"technical_doc":["https://github.com/ethereum/wiki/wiki/White-Paper"],"twitter":["https://twitter.com/ethereum"],"reddit":["https://reddit.com/r/ethereum"],"message_board":["https://forum.ethereum.org/"],"announcement":["https://bitcointalk.org/index.php?topic=428589.0"],"chat":["https://gitter.im/orgs/ethereum/rooms"],"explorer":["https://blockchain.coinmarketcap.com/chain/ethereum","https://etherscan.io/","https://ethplorer.io/"],"source_code":["https://github.com/ethereum"]},"logo":"https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png","id":1027,"name":"Ethereum","symbol":"ETH","slug":"ethereum","description":"Eth description","notice":null,"date_added":"2015-08-07T00:00:00.000Z","date_launched":"2015-08-07T00:00:00.000Z","tags":["mineable"],"platform":null,"category":"coin","self_reported_circulating_supply":null,"self_reported_market_cap":null,"self_reported_tags":null,"infinite_supply":false}},"status":{"timestamp":"2024-05-03T20:50:17.063Z","error_code":0,"error_message":"","elapsed":10,"credit_count":1,"notice":""}}''';

  Map<String, dynamic> queryParams = {
    "symbol": ids.join(","),
    "skip_invalid": "true",
  };

  Uri url = Uri.https(
      'pro-api.coinmarketcap.com', "/v2/cryptocurrency/info", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-CMC_PRO_API_KEY": apiKey});

  http.StreamedResponse responseJson = await request.send();

  var response;
  if (!(localTest ?? false)) {
    response = json.decode(await responseJson.stream.bytesToString());
  } else {
    print("USING TEST DATA");
    response = json.decode(testData);
  }

  return response;
}

Future<List<CoinPrice>> getPricesHistory(String? symbol,
    {bool? localTest}) async {
  const testData =
      '''{"data":{"id":1,"name":"Bitcoin","symbol":"BTC","is_active":1,"is_fiat":0,"quotes":[{"timestamp":"2018-06-22T19:29:37.000Z","quote":{"USD":{"price":6242.29,"volume_24h":4681670000,"market_cap":106800038746.48,"circulating_supply":4681670000,"total_supply":4681670000,"timestamp":"2018-06-22T19:29:37.000Z"}}},{"timestamp":"2018-06-22T19:34:33.000Z","quote":{"USD":{"price":6242.82,"volume_24h":4682330000,"market_cap":106809106575.84,"circulating_supply":4681670000,"total_supply":4681670000,"timestamp":"2018-06-22T19:34:33.000Z"}}}]},"status":{"timestamp":"2024-05-05T14:41:39.871Z","error_code":0,"error_message":"","elapsed":10,"credit_count":1,"notice":""}}''';

  Map<String, dynamic> queryParams = {
    "symbol": symbol,
    "skip_invalid": "true",
  };

  Uri url = Uri.https('pro-api.coinmarketcap.com',
      "/v3/cryptocurrency/quotes/historical", queryParams);

  http.Request request = http.Request("get", url);
  request.headers.addAll({"X-CMC_PRO_API_KEY": apiKey});

  http.StreamedResponse responseJson = await request.send();

  var response;
  if (!(localTest ?? false)) {
    response = json.decode(await responseJson.stream.bytesToString());
  } else {
    print("USING TEST DATA");
    response = json.decode(testData);
  }
  print(response);
  var pricesHistoryData = response['data']["quotes"];

  List<CoinPrice> pricesHistory = [];

  for (var quote in pricesHistoryData) {
    pricesHistory.add(CoinPrice(
      dateTime: DateTime.parse(quote["timestamp"]),
      price: quote["quote"]["USD"]["price"],
    ));
  }

  return pricesHistory;
}

// void main() {
//   getListing();
// }
