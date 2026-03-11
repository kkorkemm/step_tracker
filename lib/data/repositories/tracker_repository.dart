import '../domain_models/tracker.dart';
import '../domain_models/streak.dart';
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

  Future<Tracker> getTodayTracker() async {
    final steps = _stepService.currentSteps;
    return Tracker(
      date: DateTime.now(),
      steps: steps,
      distance: steps * 0.0008,
    );
  }

  // ВОЗВРАЩАЕМ шаги с учётом сброса
  int getCurrentSensorSteps() => _stepService.currentSteps;

  Stream<int> get stepStream => _stepService.stepStream;

  Future<void> saveSteps(int steps) async {
    await _storage.saveTodaySteps(steps);
  }

  Future<Streak> getStreak() async {
    return await _storage.getStreak();
  }

  // НОВЫЙ МЕТОД: сброс через сервис
  void resetStepCounter() {
    _stepService.resetSteps();
  }

  Future<void> resetTodaySteps() async {
    await _storage.resetTodaySteps();
    resetStepCounter();  // сбрасываем и счётчик шагомера
  }
}