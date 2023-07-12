import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarGraphItem extends StatelessWidget {
  final double value;
  final Widget tickerLabel;
  final Widget valueLabel;
  final VoidCallback onTap;
  final double upperBound;
  final double lowerBound;
  final Widget prefix;
  final Color positiveColor;
  final Color negativeColor;
  final bool hasVerticalLine;
  final bool valueIsPercentage;

  const BarGraphItem({
    @required this.value,
    @required this.tickerLabel,
    @required this.upperBound,
    @required this.lowerBound,
    @required this.prefix,
    @required this.hasVerticalLine,
    @required this.valueIsPercentage,
    this.positiveColor,
    this.negativeColor,
    this.valueLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;

    final range = upperBound - lowerBound;

    final positiveZeroLineFraction =
        max(0, min(1, range == 0 ? 1 : (1 - upperBound / range)));

    final barFraction = max(
      0,
      min(
        1,
        max(
          0.01, // Bar should not be invisible, show a tiny bit
          ((value.abs() - lowerBound) / range) - positiveZeroLineFraction,
        ),
      ),
    );

    final zeroLineFraction =
        isPositive ? positiveZeroLineFraction : 1 - positiveZeroLineFraction;

    // TODO: Use Theme.of(context).textTheme.bodyText1 kind of a thing here
    final textStyle = TextStyle(color: Colors.white);
    final percentageText = Text(
      valueLabel ?? valueIsPercentage
          ? '${value >= 0 ? '+' : ''}${(NumberFormat.decimalPercentPattern(decimalDigits: 1)).format(value)}'
          : NumberFormat.currency(name: '', decimalDigits: 6).format(value),
      style: textStyle,
    );

    final positiveColor = this.positiveColor ?? Colors.green;
    final negativeColor = this.negativeColor ?? Colors.red;
    final barColor = isPositive ? positiveColor : negativeColor;

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
                        if (hasVerticalLine)
                          Positioned(
                            left: isPositive ? zeroLineWidth : null,
                            right: isPositive ? null : zeroLineWidth,
                            child: Container(
                              width: 1,
                              height: barHeight,
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
