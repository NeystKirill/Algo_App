import 'dart:async';

import 'package:flutter/foundation.dart';

class PlayerController extends ChangeNotifier {
  PlayerController({required this.stepCount, Duration speed = const Duration(milliseconds: 700)})
      : _speed = speed;

  final int stepCount;
  Duration _speed;
  int _index = 0;
  bool _playing = false;
  Timer? _timer;

  int get index => _index;
  bool get isPlaying => _playing;
  Duration get speed => _speed;
  bool get isFirst => _index == 0;
  bool get isLast => _index >= stepCount - 1;

  void play() {
    if (isLast) return;
    _playing = true;
    notifyListeners();
    _scheduleTick();
  }

  void pause() {
    _timer?.cancel();
    if (_playing) {
      _playing = false;
      notifyListeners();
    }
  }

  void togglePlay() => _playing ? pause() : play();

  void stepForward() {
    if (isLast) return;
    _index++;
    notifyListeners();
  }

  void stepBackward() {
    pause();
    if (_index == 0) return;
    _index--;
    notifyListeners();
  }

  void reset() {
    pause();
    _index = 0;
    notifyListeners();
  }

  void setSpeed(Duration value) {
    _speed = value;
    if (_playing) _scheduleTick();
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer(_speed, _tick);
  }

  void _tick() {
    if (!_playing) return;
    stepForward();
    if (!isLast) {
      _scheduleTick();
    } else {
      _playing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
