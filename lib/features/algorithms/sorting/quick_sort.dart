import '../../../core/models/algo_step.dart';

List<AlgoStep> quickSortSteps(List<int> input) {
  final array = List<int>.from(input);
  final steps = <AlgoStep>[];
  final sorted = <int>{};
  int comparisons = 0;
  int swaps = 0;

  steps.add(AlgoStep(array: List.from(array), description: 'Начальный массив'));

  void sort(int low, int high) {
    if (low >= high) {
      if (low == high) sorted.add(low);
      return;
    }

    final pivot = array[high];
    steps.add(AlgoStep(
      array: List.from(array),
      markers: [high],
      sorted: sorted.toList(),
      description: 'Выбираем опорный элемент $pivot',
      comparisons: comparisons,
      swaps: swaps,
    ));

    var i = low - 1;
    for (var j = low; j < high; j++) {
      comparisons++;
      steps.add(AlgoStep(
        array: List.from(array),
        compared: [j, high],
        markers: [high],
        sorted: sorted.toList(),
        description: 'Сравниваем ${array[j]} с опорным $pivot',
        comparisons: comparisons,
        swaps: swaps,
      ));
      if (array[j] < pivot) {
        i++;
        if (i != j) {
          final tmp = array[i];
          array[i] = array[j];
          array[j] = tmp;
          swaps++;
          steps.add(AlgoStep(
            array: List.from(array),
            swapped: [i, j],
            markers: [high],
            sorted: sorted.toList(),
            description: 'Меняем местами ${array[j]} и ${array[i]}',
            comparisons: comparisons,
            swaps: swaps,
          ));
        }
      }
    }

    final pivotIndex = i + 1;
    final tmp = array[pivotIndex];
    array[pivotIndex] = array[high];
    array[high] = tmp;
    swaps++;
    sorted.add(pivotIndex);
    steps.add(AlgoStep(
      array: List.from(array),
      swapped: [pivotIndex, high],
      sorted: sorted.toList(),
      description: 'Опорный элемент встал на своё место',
      comparisons: comparisons,
      swaps: swaps,
    ));

    sort(low, pivotIndex - 1);
    sort(pivotIndex + 1, high);
  }

  sort(0, array.length - 1);

  steps.add(AlgoStep(
    array: List.from(array),
    sorted: List.generate(array.length, (i) => i),
    description: 'Массив отсортирован',
    comparisons: comparisons,
    swaps: swaps,
  ));

  return steps;
}
