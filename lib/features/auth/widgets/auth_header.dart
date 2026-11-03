import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Header shown above the login/register forms. Reuses the app's own
/// sort-visualization grammar (the same bar shapes and compare/swap/sorted
/// colors as [ArrayVisualizer]) as a small animated "frozen mid-sort" motif,
/// so the auth flow reads as part of this product rather than generic chrome.
class AuthHeader extends StatefulWidget {
  const AuthHeader({super.key, required this.subtitle, this.tagline, this.scale = 1.0});

  final String subtitle;

  /// Extra line shown under [subtitle], describing what the product
  /// actually does — used in the wide-screen brand panel, where there's
  /// room for it.
  final String? tagline;

  /// Size multiplier so the same motif can be the small header above a
  /// mobile form or the large centerpiece of the wide-screen brand panel.
  final double scale;

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  // Target heights/colors for each bar, read left-to-right as a sort in
  // progress: sorted run on the left, a compare/swap pair in the middle,
  // untouched values on the right.
  static const _heights = [26.0, 34.0, 44.0, 30.0, 38.0, 22.0, 48.0];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorFor(int index, AppColors colors) {
    if (index < 2) return colors.sorted;
    if (index == 2) return colors.swap;
    if (index == 3) return colors.compare;
    return colors.surfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scale = widget.scale;
    final barWidth = 12.0 * scale;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _heights.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3 * scale),
                    child: Container(
                      width: barWidth,
                      height: _heights[i] * scale * _progress.value,
                      decoration: BoxDecoration(
                        color: _colorFor(i, colors),
                        borderRadius: BorderRadius.circular(barWidth / 2),
                        border: i == 2
                            ? Border.all(color: colors.marker, width: 2 * scale)
                            : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(height: 16 * scale),
        Text(
          'Algo & DS',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 22 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 14 * scale.clamp(1, 1.3)),
        ),
        if (widget.tagline != null) ...[
          SizedBox(height: 10 * scale),
          Text(
            widget.tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14 * scale.clamp(1, 1.2),
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
