import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/algorithm_info.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key, required this.questions, required this.onCompleted});

  final List<QuizQuestion> questions;
  final VoidCallback onCompleted;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _questionIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;
  bool _finished = false;

  QuizQuestion get _question => widget.questions[_questionIndex];

  void _selectOption(int option) {
    if (_selectedOption != null) return;
    setState(() {
      _selectedOption = option;
      if (option == _question.correctIndex) _correctCount++;
    });
  }

  void _next() {
    if (_questionIndex == widget.questions.length - 1) {
      setState(() => _finished = true);
      widget.onCompleted();
    } else {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _questionIndex = 0;
      _selectedOption = null;
      _correctCount = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (widget.questions.isEmpty) {
      return Center(
        child: Text('Вопросы пока не добавлены', style: TextStyle(color: colors.textSecondary)),
      );
    }

    if (_finished) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 56, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Результат: $_correctCount из ${widget.questions.length}',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _restart, child: const Text('Пройти ещё раз')),
            ],
          ),
        ),
      );
    }

    final isAnswered = _selectedOption != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Вопрос ${_questionIndex + 1} из ${widget.questions.length}',
          style: TextStyle(color: colors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          _question.question,
          style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _question.options.length; i++)
          _OptionTile(
            text: _question.options[i],
            state: !isAnswered
                ? _OptionState.neutral
                : i == _question.correctIndex
                    ? _OptionState.correct
                    : i == _selectedOption
                        ? _OptionState.incorrect
                        : _OptionState.neutral,
            onTap: () => _selectOption(i),
          ),
        if (isAnswered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_question.explanation, style: TextStyle(color: colors.textPrimary)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _next,
            child: Text(_questionIndex == widget.questions.length - 1 ? 'Завершить' : 'Далее'),
          ),
        ],
      ],
    );
  }
}

enum _OptionState { neutral, correct, incorrect }

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (state) {
      _OptionState.correct => colors.success,
      _OptionState.incorrect => colors.error,
      _OptionState.neutral => colors.border,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: state == _OptionState.neutral ? 1 : 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text, style: TextStyle(color: colors.textPrimary)),
        ),
      ),
    );
  }
}
