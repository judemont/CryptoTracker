class Crypto {
  String? id;
  String? name;
  String? symbol;
  double? price;
  String? logoUrl;
  double? priceChangePercentageDay;
  String? description;
  List<String>? categories;
  String? website;
  double? ath;
  DateTime? athDate;
  double? marketCap;
  int? marketCapRank;
  double? dayHigh;
  double? dayLow;
  double? totalSupply;
  double? circulatingSupply;
  double? volume;

  Crypto({
    this.id,
    this.name,
    this.symbol,
    this.price,
    this.logoUrl,
    this.priceChangePercentageDay,
    this.description,
    this.categories,
    this.website,
    this.ath,
    this.athDate,
    this.marketCap,
    this.marketCapRank,
    this.dayHigh,
    this.dayLow,
    this.totalSupply,
    this.circulatingSupply,
    this.volume,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'price': price,
      'logoUrl': logoUrl,
      'priceChangePercentageDay': priceChangePercentageDay,
      'description': description,
      'categories': categories,
      'website': website,
      'ath': ath,
      'athDate': athDate?.toIso8601String(),
      'marketCap': marketCap,
      'marketCapRank': marketCapRank,
      'dayHigh': dayHigh,
      'dayLow': dayLow,
      'totalSupply': totalSupply,
      'circulatingSupply': circulatingSupply,
      'volume': volume,
    };
  }
}
