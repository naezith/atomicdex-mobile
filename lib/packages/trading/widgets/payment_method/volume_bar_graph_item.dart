import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/trading/widgets/payment_method/bar_graph_item.dart';

class VolumeBarGraphItem extends StatelessWidget {
  final double value;
  final Widget title;
  final Widget valueLabel;
  final VoidCallback onTap;
  final double upperBound;
  final Widget prefix;

  const VolumeBarGraphItem({
    @required this.value,
    @required this.title,
    @required this.upperBound,
    @required this.prefix,
    this.valueLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BarGraphItem(
      value: value,
      valueLabel: valueLabel,
      tickerLabel: title,
      upperBound: upperBound,
      lowerBound: 0,
      prefix: prefix,
      positiveColor: Colors.blue,
      hasVerticalLine: false,
      valueIsPercentage: false,
    );
  }
}
