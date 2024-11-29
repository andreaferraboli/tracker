import 'package:tracker/models/base_product.dart';
import 'package:tracker/models/quantiy_update_type.dart';

class DiscountedProduct extends BaseProduct {
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
    double sliderValue = 0,
    QuantityUpdateType quantityUpdateType = QuantityUpdateType.slider,
  }) : super(
          sliderValue: sliderValue,
          quantityUpdateType: quantityUpdateType,
        );

  @override
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
