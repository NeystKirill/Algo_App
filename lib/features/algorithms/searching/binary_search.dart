import '../../../core/models/algo_step.dart';

List<AlgoStep> binarySearchSteps(List<int> sortedInput, int target) {
  final array = List<int>.from(sortedInput)..sort();
  final steps = <AlgoStep>[];
  int comparisons = 0;
  var low = 0;
  var high = array.length - 1;

  steps.add(AlgoStep(
    array: List.from(array),
    markers: [low, high],
    description: 'Ищем число $target в отсортированном массиве',
  ));

  while (low <= high) {
    final mid = (low + high) ~/ 2;
    comparisons++;
    steps.add(AlgoStep(
      array: List.from(array),
      compared: [mid],
      markers: [low, high],
      description: 'Сравниваем ${array[mid]} (середина) с $target',
      comparisons: comparisons,
    ));

    if (array[mid] == target) {
      steps.add(AlgoStep(
        array: List.from(array),
        sorted: [mid],
        description: 'Найдено! $target находится на позиции $mid',
        comparisons: comparisons,
      ));
      return steps;
    } else if (array[mid] < target) {
      low = mid + 1;
      steps.add(AlgoStep(
        array: List.from(array),
        markers: [low, high],
        description: '${array[mid]} меньше $target — ищем справа',
        comparisons: comparisons,
      ));
    } else {
      high = mid - 1;
      steps.add(AlgoStep(
        array: List.from(array),
        markers: [low, high],
        description: '${array[mid]} больше $target — ищем слева',
        comparisons: comparisons,
      ));
    }
  }

  steps.add(AlgoStep(
    array: List.from(array),
    description: '$target не найден в массиве',
    comparisons: comparisons,
  ));
  return steps;
}
