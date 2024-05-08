class Crypto {
  String? id;
  String? name;
  String? symbol;
  double? price;
  String? logoUrl;
  double? priceChangePercentageDay;
  double? priceChangePercentageWeek;
  double? priceChangePercentageMonth;
  double? priceChangePercentageYear;
  String? description;
  List<String>? categories;
  String? website;
  double? ath;
  double? marketCap;
  int? marketCapRank;
  double? dayHigh;
  double? dayLow;
  double? totalSupply;
  double? circulatingSupply;

  Crypto({
    this.id,
    this.name,
    this.symbol,
    this.price,
    this.logoUrl,
    this.priceChangePercentageDay,
    this.priceChangePercentageWeek,
    this.priceChangePercentageMonth,
    this.priceChangePercentageYear,
    this.description,
    this.categories,
    this.website,
    this.ath,
    this.marketCap,
    this.marketCapRank,
    this.dayHigh,
    this.dayLow,
    this.totalSupply,
    this.circulatingSupply,
  });

  // Map<String, Object?> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'symbol': symbol,
  //     'price': price,
  //     'logoUrl': logoUrl,
  //     'priceChangePercentageDay': priceChangePercentageDay,
  //   };
  // }
}
