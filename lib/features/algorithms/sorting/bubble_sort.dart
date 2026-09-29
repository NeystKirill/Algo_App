import '../../../core/models/algo_step.dart';

List<AlgoStep> bubbleSortSteps(List<int> input) {
  final array = List<int>.from(input);
  final steps = <AlgoStep>[];
  final sorted = <int>[];
  int comparisons = 0;
  int swaps = 0;
  final n = array.length;

  steps.add(AlgoStep(
    array: List.from(array),
    description: 'Начальный массив',
  ));

  for (var i = 0; i < n - 1; i++) {
    var didSwap = false;
    for (var j = 0; j < n - 1 - i; j++) {
      comparisons++;
      steps.add(AlgoStep(
        array: List.from(array),
        compared: [j, j + 1],
        sorted: List.from(sorted),
        description: 'Сравниваем ${array[j]} и ${array[j + 1]}',
        comparisons: comparisons,
        swaps: swaps,
      ));

      if (array[j] > array[j + 1]) {
        final tmp = array[j];
        array[j] = array[j + 1];
        array[j + 1] = tmp;
        swaps++;
        didSwap = true;
        steps.add(AlgoStep(
          array: List.from(array),
          swapped: [j, j + 1],
          sorted: List.from(sorted),
          description: 'Меняем местами ${array[j + 1]} и ${array[j]}',
          comparisons: comparisons,
          swaps: swaps,
        ));
      }
    }
    sorted.insert(0, n - 1 - i);
    if (!didSwap) break;
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
