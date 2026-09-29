import '../../../core/models/algo_step.dart';

List<AlgoStep> stackDemoSteps() {
  final stack = <int>[];
  final steps = <AlgoStep>[];

  void push(int value) {
    stack.add(value);
    steps.add(AlgoStep(
      array: List.from(stack),
      swapped: [stack.length - 1],
      description: 'Push($value) — кладём элемент на вершину стека',
    ));
  }

  void pop() {
    final removedIndex = stack.length - 1;
    final value = stack[removedIndex];
    steps.add(AlgoStep(
      array: List.from(stack),
      swapped: [removedIndex],
      description: 'Pop() — снимаем $value с вершины стека',
    ));
    stack.removeLast();
    steps.add(AlgoStep(
      array: List.from(stack),
      description: 'Стек после удаления $value',
    ));
  }

  steps.add(const AlgoStep(array: [], description: 'Пустой стек'));
  push(5);
  push(3);
  push(8);
  pop();
  push(1);
  pop();
  pop();

  return steps;
}
