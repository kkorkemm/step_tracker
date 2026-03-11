import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepService {
  int _currentSteps = 0;
  int _baseSteps = 0;  // ← БАЗОВОЕ ЗНАЧЕНИЕ (для сброса)
  StreamSubscription<StepCount>? _subscription;
  final _stepController = StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepController.stream;
  
  // Текущие шаги относительно базы
  int get currentSteps => _currentSteps - _baseSteps;

  Future<bool> requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      status = await Permission.activityRecognition.request();
    }
    return status.isGranted;
  }

  Future<void> startListening() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    try {
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          _currentSteps = event.steps;
          // Отдаём шаги относительно базы
          _stepController.add(_currentSteps - _baseSteps);
          print('Шаги от шагомера: ${_currentSteps - _baseSteps}');
        },
        onError: (error) => print('Ошибка шагомера: $error'),
      );
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  // НОВЫЙ МЕТОД: сброс шагов
  void resetSteps() {
    _baseSteps = _currentSteps;  // запоминаем текущее значение как новую базу
    _stepController.add(0);      // отправляем 0 в UI
    print('Шагомер сброшен: новая база $_baseSteps');
  }

  void stopListening() {
    _subscription?.cancel();
  }

  void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}