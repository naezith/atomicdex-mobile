import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final isPositive = percentage >= 0;
    final barColor = isPositive ? Colors.green : Colors.red;

    final range = upperBoundPercentage - lowerBoundPercentage;

    final positiveZeroLineFraction =
        range == 0 ? 1 : (1 - upperBoundPercentage / range);
    final zeroLineFraction =
        isPositive ? positiveZeroLineFraction : 1 - positiveZeroLineFraction;
    final barFraction = ((percentage.abs() - lowerBoundPercentage) / range) -
        positiveZeroLineFraction;

    // TODO: Use Theme.of(context).textTheme.bodyText1 kind of a thing here
    final textStyle = TextStyle(color: Colors.white);
    final percentageText = Text(
        percentageLabel ??
            '${percentage >= 0 ? '+' : ''}${NumberFormat.decimalPercentPattern(decimalDigits: 1).format(percentage)}',
        style: textStyle);

    const barHeight = 36.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: 48,
                height: 48,
                child: prefix,
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final zeroLineWidth = constraints.maxWidth * zeroLineFraction;
                  final barWidth = constraints.maxWidth * barFraction;

                  return SizedBox(
                    height: barHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: isPositive
                              ? zeroLineWidth
                              : constraints.maxWidth *
                                  (1 - zeroLineFraction - barFraction),
                          width: barWidth,
                          child: Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: isPositive ? zeroLineWidth : null,
                          right: isPositive ? null : zeroLineWidth,
                          child: Container(
                            width: 1,
                            height: constraints.maxHeight,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: isPositive ? zeroLineWidth : null,
                          right: isPositive ? null : zeroLineWidth,
                          width: constraints.maxWidth - zeroLineWidth,
                          height: barHeight,
                          child: OverflowBox(
                            alignment: Alignment.center,
                            maxWidth: double.infinity,
                            maxHeight: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child:
                                      isPositive ? tickerLabel : percentageText,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child:
                                      isPositive ? percentageText : tickerLabel,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
