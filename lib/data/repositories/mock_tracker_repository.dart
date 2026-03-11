import 'dart:async';
import '../domain_models/tracker.dart';
import '../domain_models/streak.dart';
import '../mocks/mock_data.dart';
import 'tracker_repository.dart';

class MockTrackerRepository implements TrackerRepository {
  @override
  Future<Tracker> getTodayTracker() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockData.mockTodaySteps;
  }

  @override
  Stream<int> get stepStream async* {
    int steps = MockData.mockTodaySteps.steps;
    while (true) {
      await Future.delayed(const Duration(seconds: 2));
      steps += 50;
      yield steps;
    }
  }

  @override
  Future<Streak> getStreak() async {
    return MockData.mockStreak;
  }

  @override
  Future<void> saveSteps(int steps) async {
    print('Мок: сохранено $steps шагов');
  }

  @override
  void resetStepCounter() {
    print('Мок: сброс счётчика');
  }

  @override
  Future<void> resetTodaySteps() async {
    print('Мок: сброс шагов за сегодня');
  }
  
  @override
  int getCurrentSensorSteps() {
    // TODO: implement getCurrentSensorSteps
    throw UnimplementedError();
  }
}