import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/algorithm_info.dart';

class CodePanel extends StatefulWidget {
  const CodePanel({super.key, required this.algorithm, required this.initialLanguage});

  final AlgorithmInfo algorithm;
  final String initialLanguage;

  @override
  State<CodePanel> createState() => _CodePanelState();
}

class _CodePanelState extends State<CodePanel> {
  late String _language = widget.initialLanguage;

  static const _labels = {
    'dart': 'Dart',
    'python': 'Python',
    'javascript': 'JavaScript',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final available = widget.algorithm.codeSamples.map((s) => s.language).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final lang in available)
              ChoiceChip(
                label: Text(_labels[lang] ?? lang),
                selected: _language == lang,
                onSelected: (_) => setState(() => _language = lang),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: HighlightView(
              widget.algorithm.codeFor(_language),
              language: _language,
              theme: isDark ? atomOneDarkTheme : atomOneLightTheme,
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
