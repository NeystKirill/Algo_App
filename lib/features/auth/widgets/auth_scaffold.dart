import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'auth_header.dart';

/// Shared chrome for the login and register screens.
///
/// Below [_wideBreakpoint] (phones, narrow web windows) it's a single
/// scrolling column: a compact brand motif above a form card. At or above
/// it (desktop/web), the brand motif gets its own full-height panel next to
/// the form, instead of floating as a tiny box in a sea of empty page
/// background — which is what a centered-column layout turns into once the
/// window is wider than a phone.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.subtitle,
    required this.tagline,
    required this.child,
    this.onBack,
  });

  final String subtitle;
  final String tagline;

  /// The form itself (fields, captcha, submit button, switch-mode link) —
  /// laid out as a loose column, with no outer padding or max-width of its
  /// own; the scaffold provides the card, the width constraint and the
  /// spacing around it.
  final Widget child;

  final VoidCallback? onBack;

  static const _wideBreakpoint = 880.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= _wideBreakpoint) {
              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _BrandPane(subtitle: subtitle, tagline: tagline),
                  ),
                  Expanded(
                    flex: 4,
                    child: _FormPane(onBack: onBack, child: child),
                  ),
                ],
              );
            }
            return _NarrowLayout(
              subtitle: subtitle,
              tagline: tagline,
              onBack: onBack,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane({required this.subtitle, required this.tagline});

  final String subtitle;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surfaceVariant,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: AuthHeader(subtitle: subtitle, tagline: tagline, scale: 1.7),
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({required this.onBack, required this.child});

  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: child,
              ),
            ),
          ),
        ),
        if (onBack != null)
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
            ),
          ),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.subtitle,
    required this.tagline,
    required this.onBack,
    required this.child,
  });

  final String subtitle;
  final String tagline;
  final VoidCallback? onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: onBack == null
              ? null
              : Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  ),
                ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthHeader(subtitle: subtitle, tagline: tagline),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
