import '../../../core/models/algo_step.dart';

List<AlgoStep> queueDemoSteps() {
  final queue = <int>[];
  final steps = <AlgoStep>[];

  void enqueue(int value) {
    queue.add(value);
    steps.add(AlgoStep(
      array: List.from(queue),
      swapped: [queue.length - 1],
      description: 'Enqueue($value) — добавляем элемент в конец очереди',
    ));
  }

  void dequeue() {
    final value = queue[0];
    steps.add(AlgoStep(
      array: List.from(queue),
      swapped: [0],
      description: 'Dequeue() — убираем $value из начала очереди',
    ));
    queue.removeAt(0);
    steps.add(AlgoStep(
      array: List.from(queue),
      description: 'Очередь после удаления $value',
    ));
  }

  steps.add(const AlgoStep(array: [], description: 'Пустая очередь'));
  enqueue(4);
  enqueue(9);
  enqueue(2);
  dequeue();
  enqueue(7);
  dequeue();
  dequeue();

  return steps;
}
