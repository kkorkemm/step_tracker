import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';

class StepService {
  int _accumulated = 0;
  int _lastAbsolute = 0;
  int _currentSteps = 0;
  int _baseSteps = 0;
  bool _isInitialized = false; // флаг первого запуска
  StreamSubscription<StepCount>? _subscription;
  final _stepController = StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepController.stream;
  
  // Текущие шаги относительно базы
  int get currentSteps => _currentSteps;

  Future<bool> requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  Future<void> _loadSavedSteps() async {
    final box = await Hive.openBox<int>('steps');
    final today = DateTime.now().toIso8601String().split('T')[0];
    _accumulated = box.get(today) ?? 0;
    print('Загружено из Hive: $_accumulated шагов');
  }

  Future<void> _saveAccumulated() async {
    final box = await Hive.openBox<int>('steps');
    final today = DateTime.now().toIso8601String().split('T')[0];
    await box.put(today, _accumulated);
    print('Сохранено в Hive: $_accumulated');
  }


  Future<void> startListening() async {
    await _loadSavedSteps(); // сначала загружаем сохранённые

    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    try {
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          final absolute = event.steps;

          if (!_isInitialized) {
            // Первый запуск: запоминаем абсолютное значение и показываем накопленное
            _lastAbsolute = absolute;
            _isInitialized = true;
            _stepController.add(_accumulated);
            print('Первый запуск: абсолют=$absolute, показываем $_accumulated');
            return;
          }

          // Вычисляем разницу с прошлым абсолютным значением
          final delta = absolute - _lastAbsolute;
          if (delta > 0) {
            _accumulated += delta;
            _lastAbsolute = absolute;

            // Сохраняем новое значение в Hive
            _saveAccumulated();

            _stepController.add(_accumulated);
            print('Шаги: +$delta → $_accumulated');
          }
        },
        onError: (error) => print('Ошибка шагомера: $error'),
      );
    } catch (e) {
      print('Ошибка: $e');
    }
  }
  
  Future<void> resetSteps() async {
    _accumulated = 0;
    // _lastAbsolute не меняем, чтобы продолжать корректно считать разницу
    await _saveAccumulated();
    _stepController.add(0);
    print('Шаги сброшены');
  }


  void stopListening() {
    _subscription?.cancel();
  }

  void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}