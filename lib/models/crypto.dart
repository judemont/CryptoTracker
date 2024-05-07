class Crypto {
  String? id;
  String? name;
  String? symbol;
  double? price;
  String? logoUrl;

  Crypto({
    this.id,
    this.name,
    this.symbol,
    this.price,
    this.logoUrl,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'price': price,
      'logoUrl': logoUrl,
    };
  }

  static Crypto fromMap(Map<String, dynamic> map) {
    return Crypto(
      id: map["id"],
      name: map["name"],
      symbol: map['symbol'],
      price: map['price'],
      logoUrl: map['logoUrl'],
    );
  }
}
