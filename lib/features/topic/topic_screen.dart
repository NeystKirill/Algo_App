import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/algo_step.dart';
import '../../core/models/algorithm_info.dart';
import '../../core/models/graph_models.dart';
import '../progress/progress_provider.dart';
import '../quiz/quiz_screen.dart';
import '../settings/settings_provider.dart';
import '../visualizer/array_visualizer.dart';
import '../visualizer/graph_visualizer.dart';
import '../visualizer/player_controller.dart';
import 'widgets/code_panel.dart';
import 'widgets/playback_controls.dart';

class TopicScreen extends ConsumerStatefulWidget {
  const TopicScreen({super.key, required this.algorithm});

  final AlgorithmInfo algorithm;

  @override
  ConsumerState<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends ConsumerState<TopicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);
  List<AlgoStep>? _arraySteps;
  GraphVisualization? _graphVisualization;
  late final PlayerController _player;

  @override
  void initState() {
    super.initState();
    final speedMs = ref.read(settingsProvider).animationSpeedMs;
    if (widget.algorithm.visualizationKind == VisualizationKind.array) {
      _arraySteps = widget.algorithm.buildArraySteps!();
      _player = PlayerController(
        stepCount: _arraySteps!.length,
        speed: Duration(milliseconds: speedMs),
      );
    } else {
      _graphVisualization = widget.algorithm.buildGraphVisualization!();
      _player = PlayerController(
        stepCount: _graphVisualization!.steps.length,
        speed: Duration(milliseconds: speedMs),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final algorithm = widget.algorithm;
    final progress = ref.watch(progressProvider);
    final progressNotifier = ref.read(progressProvider.notifier);
    final isFavorite = progress.favorites.contains(algorithm.id);
    final isCompleted = progress.completed.contains(algorithm.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(algorithm.title),
        actions: [
          IconButton(
            onPressed: () => progressNotifier.toggleFavorite(algorithm.id),
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          ),
          if (isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Теория'),
            Tab(text: 'Визуализация'),
            Tab(text: 'Код'),
            Tab(text: 'Практика'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TheoryTab(algorithm: algorithm),
          _VisualizationTab(
            algorithm: algorithm,
            player: _player,
            arraySteps: _arraySteps,
            graphVisualization: _graphVisualization,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CodePanel(
              algorithm: algorithm,
              initialLanguage: ref.read(settingsProvider).codeLanguage,
            ),
          ),
          QuizView(
            questions: algorithm.quiz,
            onCompleted: () => progressNotifier.markCompleted(algorithm.id),
          ),
        ],
      ),
    );
  }
}

class _TheoryTab extends StatelessWidget {
  const _TheoryTab({required this.algorithm});

  final AlgorithmInfo algorithm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(algorithm.theory, style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.5)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _ComplexityCard(label: 'Время', value: algorithm.timeComplexity),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ComplexityCard(label: 'Память', value: algorithm.spaceComplexity),
            ),
          ],
        ),
      ],
    );
  }
}

class _ComplexityCard extends StatelessWidget {
  const _ComplexityCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualizationTab extends StatelessWidget {
  const _VisualizationTab({
    required this.algorithm,
    required this.player,
    required this.arraySteps,
    required this.graphVisualization,
  });

  final AlgorithmInfo algorithm;
  final PlayerController player;
  final List<AlgoStep>? arraySteps;
  final GraphVisualization? graphVisualization;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: player,
            builder: (context, _) {
              if (arraySteps != null) {
                final step = arraySteps![player.index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 220, child: ArrayVisualizer(step: step)),
                    const SizedBox(height: 12),
                    Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textPrimary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сравнений: ${step.comparisons}   Обменов: ${step.swaps}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                  ],
                );
              }

              final step = graphVisualization!.steps[player.index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 280,
                    child: GraphVisualizer(
                      definition: graphVisualization!.definition,
                      step: step,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          PlaybackControls(controller: player),
        ],
      ),
    );
  }
}
