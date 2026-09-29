import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/graph_models.dart';

class GraphVisualizer extends StatelessWidget {
  const GraphVisualizer({super.key, required this.definition, required this.step});

  final GraphDefinition definition;
  final GraphStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GraphPainter(definition: definition, step: step, colors: colors),
        );
      },
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({required this.definition, required this.step, required this.colors});

  final GraphDefinition definition;
  final GraphStep step;
  final AppColors colors;

  static const nodeRadius = 22.0;

  Offset _offsetFor(GraphPoint point, Size size) =>
      Offset(point.x * size.width, point.y * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final positions = <String, Offset>{
      for (final node in definition.nodes) node.id: _offsetFor(node.position, size),
    };

    final edgePaint = Paint()
      ..color = colors.border
      ..strokeWidth = 2;

    for (final edge in definition.edges) {
      final from = positions[edge.from];
      final to = positions[edge.to];
      if (from != null && to != null) {
        canvas.drawLine(from, to, edgePaint);
      }
    }

    for (final node in definition.nodes) {
      final center = positions[node.id]!;
      final isCurrent = step.current == node.id;
      final isVisited = step.visited.contains(node.id);
      final isFrontier = step.frontier.contains(node.id);

      final fillColor = isCurrent
          ? colors.marker
          : isVisited
              ? colors.sorted
              : isFrontier
                  ? colors.compare
                  : colors.surfaceVariant;

      canvas.drawCircle(
        center,
        nodeRadius,
        Paint()..color = fillColor,
      );
      canvas.drawCircle(
        center,
        nodeRadius,
        Paint()
          ..color = colors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final isDark = fillColor == colors.marker || fillColor == colors.sorted;
      final textPainter = TextPainter(
        text: TextSpan(
          text: node.id,
          style: TextStyle(
            color: isDark ? colors.onPrimary : colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) =>
      oldDelegate.step != step || oldDelegate.definition != definition;
}
