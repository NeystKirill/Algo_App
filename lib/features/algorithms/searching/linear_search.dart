import '../../../core/models/algo_step.dart';

List<AlgoStep> linearSearchSteps(List<int> input, int target) {
  final array = List<int>.from(input);
  final steps = <AlgoStep>[];
  int comparisons = 0;

  steps.add(AlgoStep(array: List.from(array), description: 'Ищем число $target'));

  for (var i = 0; i < array.length; i++) {
    comparisons++;
    steps.add(AlgoStep(
      array: List.from(array),
      compared: [i],
      description: 'Проверяем элемент ${array[i]} на позиции $i',
      comparisons: comparisons,
    ));
    if (array[i] == target) {
      steps.add(AlgoStep(
        array: List.from(array),
        sorted: [i],
        description: 'Найдено! $target находится на позиции $i',
        comparisons: comparisons,
      ));
      return steps;
    }
  }

  steps.add(AlgoStep(
    array: List.from(array),
    description: '$target не найден в массиве',
    comparisons: comparisons,
  ));
  return steps;
}
