import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class _Rule {
  const _Rule(this.label, this.isSatisfied);
  final String label;
  final bool Function(String) isSatisfied;
}

final _rules = <_Rule>[
  _Rule('Минимум 8 символов', (p) => p.length >= 8),
  _Rule(
    'Строчные и заглавные буквы',
    (p) => RegExp(r'[a-zа-я]').hasMatch(p) && RegExp(r'[A-ZА-Я]').hasMatch(p),
  ),
  _Rule('Хотя бы одна цифра', (p) => RegExp(r'\d').hasMatch(p)),
  _Rule(
    'Хотя бы один спецсимвол',
    (p) => RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-\[\]~`+=/\\;'’]''').hasMatch(p),
  ),
];

/// Live checklist of password rules, ticking off in the app's existing
/// `success` color as the user types — guidance, not a scold.
class PasswordStrengthChecklist extends StatelessWidget {
  const PasswordStrengthChecklist({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in _rules)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  rule.isSatisfied(password) ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: rule.isSatisfied(password) ? colors.success : colors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  rule.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: rule.isSatisfied(password) ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
