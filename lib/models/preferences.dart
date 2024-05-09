class Preferences {
  String? currency;

  Preferences({
    this.currency,
  });

  Map<String, Object?> toMap() {
    return {
      'currency': currency,
    };
  }

  static Preferences fromMap(Map<String, dynamic> map) {
    return Preferences(
      currency: map['currency'],
    );
  }
}
