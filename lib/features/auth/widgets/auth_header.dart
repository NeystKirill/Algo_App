import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Header shown above the login/register forms. Reuses the app's own
/// sort-visualization grammar (the same bar shapes and compare/swap/sorted
/// colors as [ArrayVisualizer]) as a small animated "frozen mid-sort" motif,
/// so the auth flow reads as part of this product rather than generic chrome.
class AuthHeader extends StatefulWidget {
  const AuthHeader({super.key, required this.subtitle});

  final String subtitle;

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

    return Column(
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
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 12,
                      height: _heights[i] * _progress.value,
                      decoration: BoxDecoration(
                        color: _colorFor(i, colors),
                        borderRadius: BorderRadius.circular(6),
                        border: i == 2 ? Border.all(color: colors.marker, width: 2) : null,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Algo & DS',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
