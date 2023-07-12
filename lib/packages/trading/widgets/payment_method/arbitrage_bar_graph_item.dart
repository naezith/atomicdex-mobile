import 'package:flutter/material.dart';
import 'package:komodo_dex/packages/trading/widgets/payment_method/bar_graph_item.dart';

class ArbitrageBarGraphItem extends StatelessWidget {
  final double percentage;
  final Widget tickerLabel;
  final Widget percentageLabel;
  final VoidCallback onTap;
  final double upperBoundPercentage;
  final double lowerBoundPercentage;
  final Widget prefix;

  const ArbitrageBarGraphItem({
    @required this.percentage,
    @required this.tickerLabel,
    @required this.upperBoundPercentage,
    @required this.lowerBoundPercentage,
    @required this.prefix,
    this.percentageLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BarGraphItem(
      percentage: percentage,
      tickerLabel: tickerLabel,
      percentageLabel: percentageLabel,
      onTap: onTap,
      upperBoundPercentage: upperBoundPercentage,
      lowerBoundPercentage: lowerBoundPercentage,
      prefix: prefix,
      hasVerticalLine: true,
      valueIsPercentage: true,
    );
  }
}
