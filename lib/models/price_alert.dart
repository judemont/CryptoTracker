class PriceAlert {
  int? id;
  String cryptoId;
  String cryptoName;
  double? thresholdAbove;
  double? thresholdBelow;
  bool isActive;
  DateTime createdAt;
  DateTime? lastTriggered;

  PriceAlert({
    this.id,
    required this.cryptoId,
    required this.cryptoName,
    this.thresholdAbove,
    this.thresholdBelow,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggered,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cryptoId': cryptoId,
      'cryptoName': cryptoName,
      'thresholdAbove': thresholdAbove,
      'thresholdBelow': thresholdBelow,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  static PriceAlert fromMap(Map<String, dynamic> map) {
    return PriceAlert(
      id: map['id'],
      cryptoId: map['cryptoId'],
      cryptoName: map['cryptoName'],
      thresholdAbove: map['thresholdAbove'],
      thresholdBelow: map['thresholdBelow'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'])
          : null,
    );
  }

  bool shouldTriggerAbove(double currentPrice) {
    return isActive &&
        thresholdAbove != null &&
        currentPrice > thresholdAbove! &&
        (lastTriggered == null ||
            DateTime.now().difference(lastTriggered!).inMinutes > 5);
  }

  bool shouldTriggerBelow(double currentPrice) {
    return isActive &&
        thresholdBelow != null &&
        currentPrice < thresholdBelow! &&
        (lastTriggered == null ||
            DateTime.now().difference(lastTriggered!).inMinutes > 5);
  }
}