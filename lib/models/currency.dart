class Currency {
  String? type;
  String? symbol;
  String? name;
  String? iconUrl;
  String? sign;

  Currency({
    this.type,
    this.symbol,
    this.name,
    this.iconUrl,
    this.sign,
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
