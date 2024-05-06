class Crypto {
  int? id;
  String? name;
  String? symbol;
  double? price;
  String? website;
  String? logoUrl;
  String? description;

  Crypto({
    this.name,
    this.symbol,
    this.price,
    this.logoUrl,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'symbol': symbol,
      'price': price,
      'logoUrl': logoUrl,
    };
  }

  static Crypto fromMap(Map<String, dynamic> map) {
    return Crypto(
      name: map["name"],
      symbol: map['symbol'],
      price: map['price'],
      logoUrl: map['logoUrl'],
    );
  }
}
