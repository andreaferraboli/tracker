import 'package:tracker/models/quantiy_update_type.dart';

abstract class BaseProduct {
  double sliderValue;
  QuantityUpdateType? quantityUpdateType;

  BaseProduct({
    this.sliderValue = 0,
    this.quantityUpdateType = QuantityUpdateType.slider,
  });
}
