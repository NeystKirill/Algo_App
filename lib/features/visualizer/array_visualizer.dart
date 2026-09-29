import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/algo_step.dart';

class ArrayVisualizer extends StatelessWidget {
  const ArrayVisualizer({super.key, required this.step});

  final AlgoStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (step.array.isEmpty) {
      return Center(
        child: Text('Пусто', style: TextStyle(color: colors.textSecondary)),
      );
    }

    final maxValue = step.array.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < step.array.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${step.array[i]}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 12 + 140 * (step.array[i] / maxValue),
                      decoration: BoxDecoration(
                        color: _colorFor(i, colors),
                        borderRadius: BorderRadius.circular(6),
                        border: step.markers.contains(i)
                            ? Border.all(color: colors.marker, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$i',
                      style: TextStyle(color: colors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorFor(int index, AppColors colors) {
    if (step.swapped.contains(index)) return colors.swap;
    if (step.compared.contains(index)) return colors.compare;
    if (step.sorted.contains(index)) return colors.sorted;
    return colors.surfaceVariant;
  }
}
