import '../../domain/models/challenge.dart';
import '../../domain/models/step_record.dart';
import '../../domain/models/streak.dart';
import '../../domain/enums/challenge_status.dart';
import '../../domain/enums/challenge_type.dart';

class MockData {
  // Мок-данные для тестирования, когда нет реального шагомера
  
  static Challenge get mockActiveChallenge {
    return Challenge(
      id: 'mock-challenge-1',
      title: '10 000 шагов',
      description: 'Проходите 10 000 шагов каждый день',
      goalSteps: 10000,
      progress: 5432,
      startDate: DateTime.now().subtract(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      status: ChallengeStatus.active,
      type: ChallengeType.personal,
    );
  }
  
  static StepRecord get mockTodaySteps {
    return StepRecord(
      date: DateTime.now(),
      steps: 5432,
      distance: 4.3,
    );
  }
  
  static Streak get mockStreak {
    return Streak(
      currentStreak: 5,
      longestStreak: 12,
      lastActiveDay: DateTime.now(),
      isActive: true,
    );
  }
  
  static List<StepRecord> get mockWeekHistory {
    return [
      StepRecord(date: DateTime.now().subtract(const Duration(days: 6)), steps: 7342, distance: 5.9),
      StepRecord(date: DateTime.now().subtract(const Duration(days: 5)), steps: 8231, distance: 6.6),
      StepRecord(date: DateTime.now().subtract(const Duration(days: 4)), steps: 6543, distance: 5.2),
      StepRecord(date: DateTime.now().subtract(const Duration(days: 3)), steps: 9876, distance: 7.9),
      StepRecord(date: DateTime.now().subtract(const Duration(days: 2)), steps: 4321, distance: 3.5),
      StepRecord(date: DateTime.now().subtract(const Duration(days: 1)), steps: 5678, distance: 4.5),
      StepRecord(date: DateTime.now(), steps: 5432, distance: 4.3),
    ];
  }
}