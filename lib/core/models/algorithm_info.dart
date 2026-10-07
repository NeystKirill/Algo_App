import 'algo_step.dart';
import 'graph_models.dart';

enum AlgoCategory { sorting, searching, dataStructures, graphs, trees }

enum Difficulty { easy, medium, hard }

enum VisualizationKind { array, graph }

extension AlgoCategoryLabel on AlgoCategory {
  String get label => switch (this) {
        AlgoCategory.sorting => 'Сортировки',
        AlgoCategory.searching => 'Поиск',
        AlgoCategory.dataStructures => 'Структуры данных',
        AlgoCategory.graphs => 'Графы',
        AlgoCategory.trees => 'Деревья',
      };
}
extension DifficultyLabel on Difficulty {
  String get label => switch (this) {
        Difficulty.easy => 'Лёгкий',
        Difficulty.medium => 'Средний',
        Difficulty.hard => 'Сложный',
      };
}

class CodeSample {
  final String language;
  final String code;

  const CodeSample({required this.language, required this.code});
}

class AlgorithmInfo {
  final String id;
  final String title;
  final AlgoCategory category;
  final Difficulty difficulty;
  final String theory;
  final String timeComplexity;
  final String spaceComplexity;
  final List<CodeSample> codeSamples;
  final VisualizationKind visualizationKind;
  final List<AlgoStep> Function()? buildArraySteps;
  final GraphVisualization Function()? buildGraphVisualization;

  const AlgorithmInfo({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.theory,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.codeSamples,
    required this.visualizationKind,
    this.buildArraySteps,
    this.buildGraphVisualization,
  });

  String codeFor(String language) {
    for (final sample in codeSamples) {
      if (sample.language == language) return sample.code;
    }
    return codeSamples.isNotEmpty ? codeSamples.first.code : '';
  }
}
