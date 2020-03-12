import 'package:flutter/material.dart';
import 'package:komodo_dex/screens/dex/history/swap_detail_page/progress_step.dart';
import 'package:komodo_dex/utils/utils.dart';

import 'detailed_swap_progress.dart';

class DetailedSwapStep extends StatelessWidget {
  const DetailedSwapStep({
    this.title,
    this.status,
    this.estimatedSpeed,
    this.actualSpeed,
    this.estimatedTotalSpeed,
    this.actualTotalSpeed,
    this.index,
  });

  final String title;
  final SwapStepStatus status;
  final Duration estimatedSpeed;
  final Duration actualSpeed;
  final Duration estimatedTotalSpeed;
  final Duration actualTotalSpeed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final Color _disabledColor = Theme.of(context).textTheme.body2.color;
    final Color _accentColor = Theme.of(context).accentColor;

    Widget _buildStepStatusIcon(SwapStepStatus status) {
      Widget icon = Container();
      switch (status) {
        case SwapStepStatus.pending:
          icon = Icon(
            Icons.radio_button_unchecked,
            size: 15,
            color: _disabledColor,
          );
          break;
        case SwapStepStatus.success:
          icon = Icon(Icons.check_circle, size: 15, color: _accentColor);
          break;
        case SwapStepStatus.inProgress:
          icon = Icon(Icons.swap_horiz, size: 15, color: _accentColor);
          break;
        default:
          {}
      }

      return Container(
        child: icon,
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 6),
            _buildStepStatusIcon(status),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style: TextStyle(
                        color: status == SwapStepStatus.pending
                            ? _disabledColor
                            : null,
                      )),
                  ProgressStep(
                    estimatedTotalSpeed: estimatedTotalSpeed,
                    actualTotalSpeed: actualTotalSpeed,
                    estimatedStepSpeed: estimatedSpeed,
                    actualStepSpeed: actualSpeed,
                  ),
                  Row(
                    children: <Widget>[
                      Text('act: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : _accentColor,
                          )),
                      Text(
                        durationFormat(actualSpeed),
                        style: TextStyle(
                          fontSize: 13,
                          color: status == SwapStepStatus.pending
                              ? _disabledColor
                              : null,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('|',
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : null,
                          )),
                      const SizedBox(width: 4),
                      Text('est: ', // TODO(yurii): localization
                          style: TextStyle(
                            fontSize: 13,
                            color: status == SwapStepStatus.pending
                                ? _disabledColor
                                : _accentColor,
                          )),
                      Text(
                        durationFormat(estimatedSpeed),
                        style: TextStyle(
                          fontSize: 13,
                          color: status == SwapStepStatus.pending
                              ? _disabledColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
