class DiscountedProduct {
  final String productId;
  final int quantityBought;
  final double discountedQuantityOwned;
  final double discountedQuantityWeightOwned;
  final int discountedQuantityUnitOwned;
  final double discountedPrice;

  DiscountedProduct({
    required this.productId,
    required this.quantityBought,
    required this.discountedQuantityOwned,
    required this.discountedQuantityWeightOwned,
    required this.discountedQuantityUnitOwned,
    required this.discountedPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantityBought': quantityBought,
      'discountedQuantityOwned': discountedQuantityOwned,
      'discountedQuantityWeightOwned': discountedQuantityWeightOwned,
      'discountedQuantityUnitOwned': discountedQuantityUnitOwned,
      'discountedPrice': discountedPrice,
    };
  }

  factory DiscountedProduct.fromJson(Map<String, dynamic> json) {
    return DiscountedProduct(
      productId: json['productId'] as String,
      quantityBought: (json['quantityBought'] as num).toInt(),
      discountedQuantityOwned:
          (json['discountedQuantityOwned'] as num).toDouble(),
      discountedQuantityWeightOwned:
          (json['discountedQuantityWeightOwned'] as num).toDouble(),
      discountedQuantityUnitOwned:
          (json['discountedQuantityUnitOwned'] as num).toInt(),
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
    );
  }
}
