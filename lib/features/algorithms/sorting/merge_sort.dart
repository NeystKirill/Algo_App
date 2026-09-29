import '../../../core/models/algo_step.dart';

List<AlgoStep> mergeSortSteps(List<int> input) {
  final array = List<int>.from(input);
  final steps = <AlgoStep>[];
  int comparisons = 0;
  int swaps = 0;

  steps.add(AlgoStep(array: List.from(array), description: 'Начальный массив'));

  void merge(int low, int mid, int high) {
    final left = array.sublist(low, mid + 1);
    final right = array.sublist(mid + 1, high + 1);
    var i = 0;
    var j = 0;
    var k = low;

    while (i < left.length && j < right.length) {
      comparisons++;
      steps.add(AlgoStep(
        array: List.from(array),
        compared: [low + i, mid + 1 + j],
        markers: [low, high],
        description: 'Сравниваем ${left[i]} и ${right[j]}',
        comparisons: comparisons,
        swaps: swaps,
      ));
      if (left[i] <= right[j]) {
        array[k] = left[i];
        i++;
      } else {
        array[k] = right[j];
        j++;
      }
      swaps++;
      steps.add(AlgoStep(
        array: List.from(array),
        swapped: [k],
        markers: [low, high],
        description: 'Записываем ${array[k]} на позицию $k',
        comparisons: comparisons,
        swaps: swaps,
      ));
      k++;
    }

    while (i < left.length) {
      array[k] = left[i];
      swaps++;
      steps.add(AlgoStep(
        array: List.from(array),
        swapped: [k],
        markers: [low, high],
        description: 'Дописываем оставшийся элемент ${array[k]}',
        comparisons: comparisons,
        swaps: swaps,
      ));
      i++;
      k++;
    }

    while (j < right.length) {
      array[k] = right[j];
      swaps++;
      steps.add(AlgoStep(
        array: List.from(array),
        swapped: [k],
        markers: [low, high],
        description: 'Дописываем оставшийся элемент ${array[k]}',
        comparisons: comparisons,
        swaps: swaps,
      ));
      j++;
      k++;
    }
  }

  void sort(int low, int high) {
    if (low >= high) return;
    final mid = (low + high) ~/ 2;
    sort(low, mid);
    sort(mid + 1, high);
    merge(low, mid, high);
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
