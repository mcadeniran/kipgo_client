enum ShuttlePaymentMethod {
  payOnDelivery,
  crypto;

  String get value => name;

  static ShuttlePaymentMethod fromString(String? value) {
    return ShuttlePaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ShuttlePaymentMethod.payOnDelivery,
    );
  }
}
