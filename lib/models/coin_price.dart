class CoinPrice {
  double? price;
  String? timestamp;

  CoinPrice({
    this.price,
    this.timestamp,
  });

  Map<String, Object?> toMap() {
    return {
      'price': price,
      'timestamp': timestamp,
    };
  }

  static CoinPrice fromMap(Map<String, dynamic> map) {
    return CoinPrice(
      price: map['price'],
      timestamp: map['timestamp'],
    );
  }
}
