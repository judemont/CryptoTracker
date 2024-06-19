class Currency {
  String? id;
  String? type;
  String? symbol;
  String? name;
  String? iconUrl;
  String? sign;

  Currency({
    this.id,
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
