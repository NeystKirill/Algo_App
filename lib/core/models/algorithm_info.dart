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

  String get icon => switch (this) {
        AlgoCategory.sorting => '🔀',
        AlgoCategory.searching => '🔍',
        AlgoCategory.dataStructures => '🧱',
        AlgoCategory.graphs => '🕸️',
        AlgoCategory.trees => '🌳',
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

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
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
  final List<QuizQuestion> quiz;
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
    required this.quiz,
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
