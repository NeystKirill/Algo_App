import '../../../core/models/algo_step.dart';

List<AlgoStep> linkedListDemoSteps() {
  final list = <int>[];
  final steps = <AlgoStep>[];

  void addLast(int value) {
    list.add(value);
    steps.add(AlgoStep(
      array: List.from(list),
      swapped: [list.length - 1],
      description: 'addLast($value) — добавляем новый узел в конец списка',
    ));
  }

  void removeFirst() {
    final value = list[0];
    steps.add(AlgoStep(
      array: List.from(list),
      swapped: [0],
      description: 'removeFirst() — удаляем узел $value из начала списка',
    ));
    list.removeAt(0);
    steps.add(AlgoStep(
      array: List.from(list),
      description: 'Связный список после удаления $value',
    ));
  }

  steps.add(const AlgoStep(array: [], description: 'Пустой связный список'));
  addLast(2);
  addLast(6);
  addLast(9);
  removeFirst();
  addLast(4);
  removeFirst();

  return steps;
}
