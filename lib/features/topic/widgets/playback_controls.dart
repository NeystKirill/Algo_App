import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../visualizer/player_controller.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key, required this.controller});

  final PlayerController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              min: 0,
              max: (controller.stepCount - 1).toDouble().clamp(0, double.infinity),
              value: controller.index.toDouble().clamp(0, (controller.stepCount - 1).toDouble()),
              onChanged: controller.stepCount > 1
                  ? (value) {
                      controller.pause();
                      final target = value.round();
                      if (target > controller.index) {
                        for (var i = controller.index; i < target; i++) {
                          controller.stepForward();
                        }
                      } else {
                        for (var i = controller.index; i > target; i--) {
                          controller.stepBackward();
                        }
                      }
                    }
                  : null,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Сброс',
                ),
                IconButton(
                  onPressed: controller.isFirst ? null : controller.stepBackward,
                  icon: const Icon(Icons.skip_previous),
                  tooltip: 'Шаг назад',
                ),
                IconButton.filled(
                  onPressed: controller.togglePlay,
                  icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow),
                  tooltip: controller.isPlaying ? 'Пауза' : 'Играть',
                ),
                IconButton(
                  onPressed: controller.isLast ? null : controller.stepForward,
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Шаг вперёд',
                ),
                const SizedBox(width: 12),
                Text('Скорость', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                Expanded(
                  child: Slider(
                    min: 200,
                    max: 1500,
                    value: controller.speed.inMilliseconds.toDouble().clamp(200, 1500),
                    onChanged: (value) =>
                        controller.setSpeed(Duration(milliseconds: value.round())),
                  ),
                ),
              ],
            ),
            Text(
              'Шаг ${controller.stepCount == 0 ? 0 : controller.index + 1} из ${controller.stepCount}',
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}
