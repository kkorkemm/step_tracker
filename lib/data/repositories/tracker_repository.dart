// ignore: unused_import
import '../domain_models/tracker.dart';
import '../services/step_service.dart';
import '../services/storage_service.dart';

class TrackerRepository {
  final StorageService _storage;
  final StepService _stepService;

  TrackerRepository({
    required StorageService storage,
    required StepService stepService,
  }) : _storage = storage,
       _stepService = stepService;

  // Получить сегодняшние шаги
  Future<Tracker> getTodayTracker() async {
    final steps = await _storage.getTodaySteps();
    return Tracker(
      date: DateTime.now(),
      steps: steps,
      distance: steps * 0.0008, // 1 шаг ≈ 0.8 метра
    );
  }

  // Получить текущие шаги с сенсора
  int getCurrentSensorSteps() => _stepService.currentSteps;

  // Сохранить шаги
  Future<void> saveSteps(int steps) async {
    await _storage.saveTodaySteps(steps);
  }

  // Подписаться на обновления шагов
  Stream<int> get stepStream => _stepService.stepStream;
}s

