import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepService {
  int _currentSteps = 0;
  StreamSubscription<StepCount>? _subscription;
  final _stepController = StreamController<int>.broadcast();

  // Поток для подписки на изменения шагов
  Stream<int> get stepStream => _stepController.stream;

  // Текущее количество шагов
  int get currentSteps => _currentSteps;

  // Запрос разрешения на использование шагомера
  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  // Запуск отслеживания шагов
  Future<void> startListening() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      _stepController.addError('Нет разрешения на отслеживание активности');
      return;
    }

    try {
      _subscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          _currentSteps = event.steps;
          _stepController.add(_currentSteps);
          print('Шагомер: $_currentSteps шагов');
        },
        onError: (error) {
          print('Ошибка шагомера: $error');
          _stepController.addError('Ошибка шагомера: $error');
        },
      );
    } catch (e) {
      print('Не удалось инициализировать шагомер: $e');
      _stepController.addError('Не удалось инициализировать шагомер');
    }
  }

  // Остановка отслеживания
  void stopListening() {
    _subscription?.cancel();
  }

  // Очистка ресурсов
  void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}