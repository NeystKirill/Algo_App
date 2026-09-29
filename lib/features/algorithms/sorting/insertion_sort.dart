import '../../../core/models/algo_step.dart';

List<AlgoStep> insertionSortSteps(List<int> input) {
  final array = List<int>.from(input);
  final steps = <AlgoStep>[];
  int comparisons = 0;
  int swaps = 0;
  final n = array.length;

  steps.add(AlgoStep(array: List.from(array), description: 'Начальный массив'));

  for (var i = 1; i < n; i++) {
    final key = array[i];
    var j = i - 1;
    steps.add(AlgoStep(
      array: List.from(array),
      markers: [i],
      description: 'Берём элемент $key для вставки',
      comparisons: comparisons,
      swaps: swaps,
    ));

    while (j >= 0) {
      comparisons++;
      steps.add(AlgoStep(
        array: List.from(array),
        compared: [j, j + 1],
        sorted: List.generate(i, (k) => k),
        description: 'Сравниваем ${array[j]} и $key',
        comparisons: comparisons,
        swaps: swaps,
      ));
      if (array[j] > key) {
        array[j + 1] = array[j];
        j--;
        swaps++;
        steps.add(AlgoStep(
          array: List.from(array),
          swapped: [j + 1],
          description: 'Сдвигаем ${array[j + 1]} вправо',
          comparisons: comparisons,
          swaps: swaps,
        ));
      } else {
        break;
      }
    }
    array[j + 1] = key;
    steps.add(AlgoStep(
      array: List.from(array),
      swapped: [j + 1],
      sorted: List.generate(i + 1, (k) => k),
      description: 'Вставляем $key на позицию ${j + 1}',
      comparisons: comparisons,
      swaps: swaps,
    ));
  }

  steps.add(AlgoStep(
    array: List.from(array),
    sorted: List.generate(n, (i) => i),
    description: 'Массив отсортирован',
    comparisons: comparisons,
    swaps: swaps,
  ));

  return steps;
}
