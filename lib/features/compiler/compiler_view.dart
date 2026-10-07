import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/algorithm_info.dart';
import 'compiler_repository.dart';

class CompilerView extends StatefulWidget {
  const CompilerView({super.key, required this.algorithm, required this.initialLanguage});

  final AlgorithmInfo algorithm;
  final String initialLanguage;

  @override
  State<CompilerView> createState() => _CompilerViewState();
}

class _CompilerViewState extends State<CompilerView> {
  static const _labels = {'dart': 'Dart', 'python': 'Python', 'javascript': 'JavaScript'};

  late String _language = widget.initialLanguage;
  late final _codeController = TextEditingController(
    text: widget.algorithm.codeFor(widget.initialLanguage),
  );

  bool _running = false;
  ExecutionResult? _result;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final result = await runCode(language: _language, code: _codeController.text);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final available = widget.algorithm.codeSamples.map((s) => s.language).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final lang in available)
                ChoiceChip(
                  label: Text(_labels[lang] ?? lang),
                  selected: _language == lang,
                  onSelected: (_) => setState(() {
                    _language = lang;
                    _codeController.text = widget.algorithm.codeFor(lang);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _running ? null : _run,
            child: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Запустить'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_result != null) ...[
            const SizedBox(height: 12),
            if (_result!.stdout.isNotEmpty)
              Text(_result!.stdout, style: const TextStyle(fontFamily: 'monospace')),
            if (_result!.stderr.isNotEmpty)
              Text(
                _result!.stderr,
                style: const TextStyle(fontFamily: 'monospace', color: Colors.red),
              ),
          ],
        ],
      ),
    );
  }
}
