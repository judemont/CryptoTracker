class Currency {
  String? symbol;
  String? name;
  String? iconUrl;
  double? rate;

  Currency({
    this.symbol,
    this.name,
    this.iconUrl,
    this.rate,
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
