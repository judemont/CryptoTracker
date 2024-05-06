double roundPrice(double price) {
  return double.parse(
      price.toStringAsFixed(5 - price.toString().split(".")[0].length));
}
