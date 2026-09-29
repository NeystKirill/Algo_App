import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Тема оформления', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Система')),
              ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (selection) => notifier.setThemeMode(selection.first),
          ),
          const SizedBox(height: 24),
          const Text('Скорость анимации по умолчанию',
              style: TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            min: 200,
            max: 1500,
            divisions: 13,
            value: settings.animationSpeedMs.toDouble(),
            label: '${settings.animationSpeedMs} мс',
            onChanged: (value) => notifier.setAnimationSpeed(value.round()),
          ),
          const SizedBox(height: 24),
          const Text('Язык кода по умолчанию', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final lang in const ['dart', 'python', 'javascript'])
                ChoiceChip(
                  label: Text(lang),
                  selected: settings.codeLanguage == lang,
                  onSelected: (_) => notifier.setCodeLanguage(lang),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
