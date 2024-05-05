class Crypto {
  int? id;
  String? name;
  String? symbol;
  double? price;
  String? website;
  String? logoUrl;
  String? description;

  Crypto({
    this.id,
    this.name,
    this.symbol,
    this.price,
    this.website,
    this.logoUrl,
    this.description,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'price': price,
      'website': website,
      'logoUrl': logoUrl,
      'description': description,
    };
  }

  static Crypto fromMap(Map<String, dynamic> map) {
    return Crypto(
      id: map['id'],
      name: map["name"],
      symbol: map['symbol'],
      price: map['price'],
      website: map['website'],
      logoUrl: map['logoUrl'],
      description: map['description'],
    );
  }
}
