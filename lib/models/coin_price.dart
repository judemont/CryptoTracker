class CoinPrice {
  double? price;
  DateTime? dateTime;

  CoinPrice({
    this.price,
    this.dateTime,
  });

  Map<String, Object?> toMap() {
    return {
      'price': price,
      'timestamp': dateTime,
    };
  }

  static CoinPrice fromMap(Map<String, dynamic> map) {
    return CoinPrice(
      price: map['price'],
      dateTime: map['timestamp'],
    );
  }
}
