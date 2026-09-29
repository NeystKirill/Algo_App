import '../../core/models/algorithm_info.dart';
import 'data_structures/linked_list_steps.dart';
import 'data_structures/queue_steps.dart';
import 'data_structures/stack_steps.dart';
import 'graphs/bfs.dart';
import 'graphs/dfs.dart';
import 'searching/binary_search.dart';
import 'searching/linear_search.dart';
import 'sorting/bubble_sort.dart';
import 'sorting/insertion_sort.dart';
import 'sorting/merge_sort.dart';
import 'sorting/quick_sort.dart';
import 'trees/tree_traversal.dart';

final List<AlgorithmInfo> algorithmRegistry = [
  AlgorithmInfo(
    id: 'bubble_sort',
    title: 'Сортировка пузырьком',
    category: AlgoCategory.sorting,
    difficulty: Difficulty.easy,
    theory:
        'Сортировка пузырьком проходит по массиву несколько раз, сравнивая соседние элементы '
        'и меняя их местами, если они стоят в неправильном порядке. После каждого прохода '
        'самый большой из оставшихся элементов "всплывает" в конец массива.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => bubbleSortSteps([8, 3, 9, 1, 6, 4, 2]),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void bubbleSort(List<int> arr) {
  for (var i = 0; i < arr.length - 1; i++) {
    for (var j = 0; j < arr.length - 1 - i; j++) {
      if (arr[j] > arr[j + 1]) {
        final tmp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = tmp;
      }
    }
  }
}
'''),
      CodeSample(language: 'python', code: r'''
def bubble_sort(arr):
    n = len(arr)
    for i in range(n - 1):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
'''),
      CodeSample(language: 'javascript', code: r'''
function bubbleSort(arr) {
  for (let i = 0; i < arr.length - 1; i++) {
    for (let j = 0; j < arr.length - 1 - i; j++) {
      if (arr[j] > arr[j + 1]) {
        [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
      }
    }
  }
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Какова временная сложность сортировки пузырьком в худшем случае?',
        options: ['O(n)', 'O(n log n)', 'O(n²)', 'O(1)'],
        correctIndex: 2,
        explanation: 'В худшем случае требуется n² сравнений — по проходу на каждый элемент.',
      ),
      QuizQuestion(
        question: 'Что происходит на каждом проходе алгоритма?',
        options: [
          'Массив делится пополам',
          'Самый большой оставшийся элемент "всплывает" в конец',
          'Выбирается опорный элемент',
          'Элементы объединяются попарно',
        ],
        correctIndex: 1,
        explanation: 'После каждого прохода очередной наибольший элемент занимает своё место.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'insertion_sort',
    title: 'Сортировка вставками',
    category: AlgoCategory.sorting,
    difficulty: Difficulty.easy,
    theory:
        'Сортировка вставками строит отсортированную часть массива слева направо. На каждом '
        'шаге очередной элемент вставляется на нужное место среди уже отсортированных, сдвигая '
        'большие элементы вправо.',
    timeComplexity: 'O(n²)',
    spaceComplexity: 'O(1)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => insertionSortSteps([7, 2, 8, 4, 1, 5]),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void insertionSort(List<int> arr) {
  for (var i = 1; i < arr.length; i++) {
    final key = arr[i];
    var j = i - 1;
    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = key;
  }
}
'''),
      CodeSample(language: 'python', code: r'''
def insertion_sort(arr):
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        while j >= 0 and arr[j] > key:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
'''),
      CodeSample(language: 'javascript', code: r'''
function insertionSort(arr) {
  for (let i = 1; i < arr.length; i++) {
    const key = arr[i];
    let j = i - 1;
    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = key;
  }
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'На каком принципе основана сортировка вставками?',
        options: [
          'Разделяй и властвуй',
          'Вставка элемента в уже отсортированную часть',
          'Выбор минимума на каждом шаге',
          'Сравнение всех пар элементов',
        ],
        correctIndex: 1,
        explanation: 'Каждый новый элемент вставляется на своё место среди отсортированных.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'quick_sort',
    title: 'Быстрая сортировка (QuickSort)',
    category: AlgoCategory.sorting,
    difficulty: Difficulty.medium,
    theory:
        'Быстрая сортировка выбирает опорный элемент (pivot) и разделяет массив на две части: '
        'элементы меньше опорного и элементы больше. Затем обе части сортируются рекурсивно. '
        'В среднем случае это один из самых быстрых алгоритмов сортировки.',
    timeComplexity: 'O(n log n) в среднем, O(n²) в худшем',
    spaceComplexity: 'O(log n)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => quickSortSteps([6, 1, 8, 3, 9, 2, 5]),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void quickSort(List<int> arr, int low, int high) {
  if (low >= high) return;
  final pivot = arr[high];
  var i = low - 1;
  for (var j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      final tmp = arr[i];
      arr[i] = arr[j];
      arr[j] = tmp;
    }
  }
  final tmp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = tmp;
  quickSort(arr, low, i);
  quickSort(arr, i + 2, high);
}
'''),
      CodeSample(language: 'python', code: r'''
def quick_sort(arr, low, high):
    if low >= high:
        return
    pivot = arr[high]
    i = low - 1
    for j in range(low, high):
        if arr[j] < pivot:
            i += 1
            arr[i], arr[j] = arr[j], arr[i]
    arr[i + 1], arr[high] = arr[high], arr[i + 1]
    quick_sort(arr, low, i)
    quick_sort(arr, i + 2, high)
'''),
      CodeSample(language: 'javascript', code: r'''
function quickSort(arr, low, high) {
  if (low >= high) return;
  const pivot = arr[high];
  let i = low - 1;
  for (let j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
  }
  [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
  quickSort(arr, low, i);
  quickSort(arr, i + 2, high);
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Что такое опорный элемент (pivot)?',
        options: [
          'Первый элемент массива всегда',
          'Элемент, относительно которого массив делится на части',
          'Самый маленький элемент массива',
          'Средний индекс массива',
        ],
        correctIndex: 1,
        explanation: 'Опорный элемент используется, чтобы разделить массив на меньшие и большие элементы.',
      ),
      QuizQuestion(
        question: 'Какая сложность у QuickSort в худшем случае?',
        options: ['O(n log n)', 'O(n²)', 'O(log n)', 'O(n)'],
        correctIndex: 1,
        explanation: 'При неудачном выборе опорного элемента сложность деградирует до O(n²).',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'merge_sort',
    title: 'Сортировка слиянием',
    category: AlgoCategory.sorting,
    difficulty: Difficulty.medium,
    theory:
        'Сортировка слиянием делит массив пополам рекурсивно, пока не останутся элементы по '
        'одному, а затем последовательно сливает отсортированные половины в единый '
        'отсортированный массив.',
    timeComplexity: 'O(n log n)',
    spaceComplexity: 'O(n)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => mergeSortSteps([9, 4, 7, 1, 8, 2, 6]),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void mergeSort(List<int> arr, int low, int high) {
  if (low >= high) return;
  final mid = (low + high) ~/ 2;
  mergeSort(arr, low, mid);
  mergeSort(arr, mid + 1, high);
  merge(arr, low, mid, high);
}

void merge(List<int> arr, int low, int mid, int high) {
  final left = arr.sublist(low, mid + 1);
  final right = arr.sublist(mid + 1, high + 1);
  var i = 0, j = 0, k = low;
  while (i < left.length && j < right.length) {
    arr[k++] = left[i] <= right[j] ? left[i++] : right[j++];
  }
  while (i < left.length) arr[k++] = left[i++];
  while (j < right.length) arr[k++] = right[j++];
}
'''),
      CodeSample(language: 'python', code: r'''
def merge_sort(arr, low, high):
    if low >= high:
        return
    mid = (low + high) // 2
    merge_sort(arr, low, mid)
    merge_sort(arr, mid + 1, high)
    merge(arr, low, mid, high)

def merge(arr, low, mid, high):
    left = arr[low:mid + 1]
    right = arr[mid + 1:high + 1]
    i = j = 0
    k = low
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            arr[k] = left[i]
            i += 1
        else:
            arr[k] = right[j]
            j += 1
        k += 1
    while i < len(left):
        arr[k] = left[i]
        i += 1
        k += 1
    while j < len(right):
        arr[k] = right[j]
        j += 1
        k += 1
'''),
      CodeSample(language: 'javascript', code: r'''
function mergeSort(arr, low, high) {
  if (low >= high) return;
  const mid = Math.floor((low + high) / 2);
  mergeSort(arr, low, mid);
  mergeSort(arr, mid + 1, high);
  merge(arr, low, mid, high);
}

function merge(arr, low, mid, high) {
  const left = arr.slice(low, mid + 1);
  const right = arr.slice(mid + 1, high + 1);
  let i = 0, j = 0, k = low;
  while (i < left.length && j < right.length) {
    arr[k++] = left[i] <= right[j] ? left[i++] : right[j++];
  }
  while (i < left.length) arr[k++] = left[i++];
  while (j < right.length) arr[k++] = right[j++];
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Какой приём лежит в основе сортировки слиянием?',
        options: [
          'Разделяй и властвуй',
          'Жадный алгоритм',
          'Динамическое программирование',
          'Поиск с возвратом',
        ],
        correctIndex: 0,
        explanation: 'Массив рекурсивно делится на части, а затем части сливаются обратно.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'linear_search',
    title: 'Линейный поиск',
    category: AlgoCategory.searching,
    difficulty: Difficulty.easy,
    theory:
        'Линейный поиск проверяет элементы массива один за другим, пока не найдёт искомое '
        'значение или не дойдёт до конца массива. Не требует, чтобы массив был отсортирован.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(1)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => linearSearchSteps([5, 2, 9, 1, 7, 3], 7),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
int linearSearch(List<int> arr, int target) {
  for (var i = 0; i < arr.length; i++) {
    if (arr[i] == target) return i;
  }
  return -1;
}
'''),
      CodeSample(language: 'python', code: r'''
def linear_search(arr, target):
    for i, value in enumerate(arr):
        if value == target:
            return i
    return -1
'''),
      CodeSample(language: 'javascript', code: r'''
function linearSearch(arr, target) {
  for (let i = 0; i < arr.length; i++) {
    if (arr[i] === target) return i;
  }
  return -1;
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Нужно ли сортировать массив перед линейным поиском?',
        options: ['Да, обязательно', 'Нет, не требуется', 'Только для чисел', 'Только для строк'],
        correctIndex: 1,
        explanation: 'Линейный поиск проверяет элементы по порядку и не требует сортировки.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'binary_search',
    title: 'Бинарный поиск',
    category: AlgoCategory.searching,
    difficulty: Difficulty.easy,
    theory:
        'Бинарный поиск работает только на отсортированном массиве. На каждом шаге он '
        'сравнивает искомое значение со средним элементом и отбрасывает половину массива, '
        'в которой значения точно быть не может.',
    timeComplexity: 'O(log n)',
    spaceComplexity: 'O(1)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: () => binarySearchSteps([1, 3, 4, 6, 7, 9, 11, 14], 7),
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
int binarySearch(List<int> arr, int target) {
  var low = 0, high = arr.length - 1;
  while (low <= high) {
    final mid = (low + high) ~/ 2;
    if (arr[mid] == target) return mid;
    if (arr[mid] < target) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }
  return -1;
}
'''),
      CodeSample(language: 'python', code: r'''
def binary_search(arr, target):
    low, high = 0, len(arr) - 1
    while low <= high:
        mid = (low + high) // 2
        if arr[mid] == target:
            return mid
        if arr[mid] < target:
            low = mid + 1
        else:
            high = mid - 1
    return -1
'''),
      CodeSample(language: 'javascript', code: r'''
function binarySearch(arr, target) {
  let low = 0, high = arr.length - 1;
  while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    if (arr[mid] === target) return mid;
    if (arr[mid] < target) low = mid + 1;
    else high = mid - 1;
  }
  return -1;
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Обязательное условие для бинарного поиска?',
        options: [
          'Массив должен быть отсортирован',
          'Массив должен содержать только чётные числа',
          'Массив должен быть небольшим',
          'Условий нет',
        ],
        correctIndex: 0,
        explanation: 'Бинарный поиск делит массив пополам, что работает корректно только на отсортированных данных.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'stack',
    title: 'Стек',
    category: AlgoCategory.dataStructures,
    difficulty: Difficulty.easy,
    theory:
        'Стек — структура данных LIFO (последним пришёл — первым вышел). Основные операции: '
        'push (добавить элемент на вершину) и pop (снять элемент с вершины).',
    timeComplexity: 'O(1) для push/pop',
    spaceComplexity: 'O(n)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: stackDemoSteps,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
class Stack<T> {
  final _items = <T>[];
  void push(T value) => _items.add(value);
  T pop() => _items.removeLast();
  T get top => _items.last;
  bool get isEmpty => _items.isEmpty;
}
'''),
      CodeSample(language: 'python', code: r'''
class Stack:
    def __init__(self):
        self.items = []

    def push(self, value):
        self.items.append(value)

    def pop(self):
        return self.items.pop()
'''),
      CodeSample(language: 'javascript', code: r'''
class Stack {
  #items = [];
  push(value) { this.#items.push(value); }
  pop() { return this.#items.pop(); }
  get top() { return this.#items.at(-1); }
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Какой принцип работы у стека?',
        options: ['FIFO', 'LIFO', 'Случайный доступ', 'Приоритетная очередь'],
        correctIndex: 1,
        explanation: 'Стек работает по принципу LIFO — последним пришёл, первым вышел.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'queue',
    title: 'Очередь',
    category: AlgoCategory.dataStructures,
    difficulty: Difficulty.easy,
    theory:
        'Очередь — структура данных FIFO (первым пришёл — первым вышел). Основные операции: '
        'enqueue (добавить элемент в конец) и dequeue (удалить элемент из начала).',
    timeComplexity: 'O(1) для enqueue/dequeue',
    spaceComplexity: 'O(n)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: queueDemoSteps,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
class Queue<T> {
  final _items = <T>[];
  void enqueue(T value) => _items.add(value);
  T dequeue() => _items.removeAt(0);
  bool get isEmpty => _items.isEmpty;
}
'''),
      CodeSample(language: 'python', code: r'''
from collections import deque

class Queue:
    def __init__(self):
        self.items = deque()

    def enqueue(self, value):
        self.items.append(value)

    def dequeue(self):
        return self.items.popleft()
'''),
      CodeSample(language: 'javascript', code: r'''
class Queue {
  #items = [];
  enqueue(value) { this.#items.push(value); }
  dequeue() { return this.#items.shift(); }
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Какой элемент удаляется первым в очереди?',
        options: [
          'Последний добавленный',
          'Первый добавленный',
          'Случайный элемент',
          'Самый большой',
        ],
        correctIndex: 1,
        explanation: 'Очередь работает по принципу FIFO — первым пришёл, первым вышел.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'linked_list',
    title: 'Связный список',
    category: AlgoCategory.dataStructures,
    difficulty: Difficulty.easy,
    theory:
        'Связный список состоит из узлов, каждый из которых хранит значение и ссылку на '
        'следующий узел. В отличие от массива, вставка и удаление в начале списка выполняются '
        'за O(1), но нет прямого доступа по индексу.',
    timeComplexity: 'O(1) для добавления/удаления по краям, O(n) для поиска',
    spaceComplexity: 'O(n)',
    visualizationKind: VisualizationKind.array,
    buildArraySteps: linkedListDemoSteps,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
class Node<T> {
  T value;
  Node<T>? next;
  Node(this.value);
}

class LinkedList<T> {
  Node<T>? head;
  Node<T>? tail;

  void addLast(T value) {
    final node = Node(value);
    if (head == null) {
      head = tail = node;
    } else {
      tail!.next = node;
      tail = node;
    }
  }

  T removeFirst() {
    final value = head!.value;
    head = head!.next;
    return value;
  }
}
'''),
      CodeSample(language: 'python', code: r'''
class Node:
    def __init__(self, value):
        self.value = value
        self.next = None

class LinkedList:
    def __init__(self):
        self.head = None
        self.tail = None

    def add_last(self, value):
        node = Node(value)
        if self.head is None:
            self.head = self.tail = node
        else:
            self.tail.next = node
            self.tail = node

    def remove_first(self):
        value = self.head.value
        self.head = self.head.next
        return value
'''),
      CodeSample(language: 'javascript', code: r'''
class Node {
  constructor(value) {
    this.value = value;
    this.next = null;
  }
}

class LinkedList {
  head = null;
  tail = null;

  addLast(value) {
    const node = new Node(value);
    if (!this.head) {
      this.head = this.tail = node;
    } else {
      this.tail.next = node;
      this.tail = node;
    }
  }

  removeFirst() {
    const value = this.head.value;
    this.head = this.head.next;
    return value;
  }
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Чем связный список отличается от массива?',
        options: [
          'Доступ по индексу выполняется за O(1)',
          'Элементы хранятся не подряд в памяти, а через ссылки',
          'Он не может расти в размере',
          'Он всегда быстрее массива',
        ],
        correctIndex: 1,
        explanation: 'Узлы связного списка хранят ссылку на следующий элемент, а не лежат подряд в памяти.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'bfs',
    title: 'Поиск в ширину (BFS)',
    category: AlgoCategory.graphs,
    difficulty: Difficulty.medium,
    theory:
        'Обход в ширину исследует граф уровень за уровнем: сначала посещаются все соседи '
        'стартовой вершины, затем соседи соседей и так далее. Для этого используется очередь.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    visualizationKind: VisualizationKind.graph,
    buildGraphVisualization: bfsDemo,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
List<String> bfs(Map<String, List<String>> graph, String start) {
  final visited = <String>[start];
  final queue = <String>[start];
  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    for (final neighbor in graph[node]!) {
      if (!visited.contains(neighbor)) {
        visited.add(neighbor);
        queue.add(neighbor);
      }
    }
  }
  return visited;
}
'''),
      CodeSample(language: 'python', code: r'''
from collections import deque

def bfs(graph, start):
    visited = [start]
    queue = deque([start])
    while queue:
        node = queue.popleft()
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.append(neighbor)
                queue.append(neighbor)
    return visited
'''),
      CodeSample(language: 'javascript', code: r'''
function bfs(graph, start) {
  const visited = [start];
  const queue = [start];
  while (queue.length) {
    const node = queue.shift();
    for (const neighbor of graph[node]) {
      if (!visited.includes(neighbor)) {
        visited.push(neighbor);
        queue.push(neighbor);
      }
    }
  }
  return visited;
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Какую структуру данных использует BFS?',
        options: ['Стек', 'Очередь', 'Хеш-таблицу', 'Дерево отрезков'],
        correctIndex: 1,
        explanation: 'BFS хранит вершины для посещения в очереди, обрабатывая их по порядку добавления.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'dfs',
    title: 'Поиск в глубину (DFS)',
    category: AlgoCategory.graphs,
    difficulty: Difficulty.medium,
    theory:
        'Обход в глубину идёт по графу максимально глубоко, прежде чем вернуться назад и '
        'попробовать другой путь. Обычно реализуется рекурсивно или с помощью стека.',
    timeComplexity: 'O(V + E)',
    spaceComplexity: 'O(V)',
    visualizationKind: VisualizationKind.graph,
    buildGraphVisualization: dfsDemo,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void dfs(Map<String, List<String>> graph, String node, List<String> visited) {
  visited.add(node);
  for (final neighbor in graph[node]!) {
    if (!visited.contains(neighbor)) {
      dfs(graph, neighbor, visited);
    }
  }
}
'''),
      CodeSample(language: 'python', code: r'''
def dfs(graph, node, visited=None):
    if visited is None:
        visited = []
    visited.append(node)
    for neighbor in graph[node]:
        if neighbor not in visited:
            dfs(graph, neighbor, visited)
    return visited
'''),
      CodeSample(language: 'javascript', code: r'''
function dfs(graph, node, visited = []) {
  visited.push(node);
  for (const neighbor of graph[node]) {
    if (!visited.includes(neighbor)) {
      dfs(graph, neighbor, visited);
    }
  }
  return visited;
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Как обычно реализуется DFS?',
        options: [
          'Только итеративно с очередью',
          'Рекурсивно или с помощью стека',
          'Только с приоритетной очередью',
          'DFS нельзя реализовать программно',
        ],
        correctIndex: 1,
        explanation: 'DFS естественно выражается через рекурсию (или явный стек), уходя вглубь перед возвратом.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'tree_preorder',
    title: 'Обход дерева: pre-order',
    category: AlgoCategory.trees,
    difficulty: Difficulty.easy,
    theory:
        'При обходе pre-order сначала посещается сам узел, затем рекурсивно левое поддерево, '
        'а затем правое. Такой обход часто используют для копирования структуры дерева.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h), где h — высота дерева',
    visualizationKind: VisualizationKind.graph,
    buildGraphVisualization: preOrderDemo,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void preOrder(Node? node, void Function(int) visit) {
  if (node == null) return;
  visit(node.value);
  preOrder(node.left, visit);
  preOrder(node.right, visit);
}
'''),
      CodeSample(language: 'python', code: r'''
def pre_order(node, visit):
    if node is None:
        return
    visit(node.value)
    pre_order(node.left, visit)
    pre_order(node.right, visit)
'''),
      CodeSample(language: 'javascript', code: r'''
function preOrder(node, visit) {
  if (!node) return;
  visit(node.value);
  preOrder(node.left, visit);
  preOrder(node.right, visit);
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'В каком порядке pre-order посещает узел и поддеревья?',
        options: [
          'Левое, узел, правое',
          'Узел, левое, правое',
          'Левое, правое, узел',
          'Правое, узел, левое',
        ],
        correctIndex: 1,
        explanation: 'Pre-order: сначала сам узел, затем левое поддерево, затем правое.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'tree_inorder',
    title: 'Обход дерева: in-order',
    category: AlgoCategory.trees,
    difficulty: Difficulty.easy,
    theory:
        'При обходе in-order сначала рекурсивно обходится левое поддерево, затем посещается '
        'сам узел, а затем правое поддерево. Для бинарного дерева поиска этот обход выдаёт '
        'значения по возрастанию.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h), где h — высота дерева',
    visualizationKind: VisualizationKind.graph,
    buildGraphVisualization: inOrderDemo,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void inOrder(Node? node, void Function(int) visit) {
  if (node == null) return;
  inOrder(node.left, visit);
  visit(node.value);
  inOrder(node.right, visit);
}
'''),
      CodeSample(language: 'python', code: r'''
def in_order(node, visit):
    if node is None:
        return
    in_order(node.left, visit)
    visit(node.value)
    in_order(node.right, visit)
'''),
      CodeSample(language: 'javascript', code: r'''
function inOrder(node, visit) {
  if (!node) return;
  inOrder(node.left, visit);
  visit(node.value);
  inOrder(node.right, visit);
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Что выдаёт in-order обход для бинарного дерева поиска?',
        options: [
          'Значения в случайном порядке',
          'Значения по убыванию',
          'Значения по возрастанию',
          'Только листья дерева',
        ],
        correctIndex: 2,
        explanation: 'In-order обход бинарного дерева поиска возвращает элементы в отсортированном порядке.',
      ),
    ],
  ),
  AlgorithmInfo(
    id: 'tree_postorder',
    title: 'Обход дерева: post-order',
    category: AlgoCategory.trees,
    difficulty: Difficulty.medium,
    theory:
        'При обходе post-order сначала рекурсивно обходятся левое и правое поддеревья, а сам '
        'узел посещается последним. Такой обход часто используют для удаления дерева или '
        'вычисления выражений.',
    timeComplexity: 'O(n)',
    spaceComplexity: 'O(h), где h — высота дерева',
    visualizationKind: VisualizationKind.graph,
    buildGraphVisualization: postOrderDemo,
    codeSamples: const [
      CodeSample(language: 'dart', code: r'''
void postOrder(Node? node, void Function(int) visit) {
  if (node == null) return;
  postOrder(node.left, visit);
  postOrder(node.right, visit);
  visit(node.value);
}
'''),
      CodeSample(language: 'python', code: r'''
def post_order(node, visit):
    if node is None:
        return
    post_order(node.left, visit)
    post_order(node.right, visit)
    visit(node.value)
'''),
      CodeSample(language: 'javascript', code: r'''
function postOrder(node, visit) {
  if (!node) return;
  postOrder(node.left, visit);
  postOrder(node.right, visit);
  visit(node.value);
}
'''),
    ],
    quiz: const [
      QuizQuestion(
        question: 'Когда посещается сам узел при post-order обходе?',
        options: ['Первым', 'Между поддеревьями', 'Последним', 'Обход не посещает узлы'],
        correctIndex: 2,
        explanation: 'Post-order сначала обходит оба поддерева и лишь затем посещает сам узел.',
      ),
    ],
  ),
];
