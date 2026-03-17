import '../domain_models/challenge.dart';
import '../domain_models/streak.dart';
import '../domain_models/tracker.dart';
import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';

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
  
  static Tracker get mockTodaySteps {
    return Tracker(
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

  static Challenge get mockChallenge {
    return Challenge(
      id: 'mock-challenge-1',
      title: 'Мартовский марафон',
      description: '10 000 шагов ежедневно',
      goalSteps: 10000,
      progress: 5432,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      status: ChallengeStatus.active,
      type: ChallengeType.personal,
    );
  }
  
  static List<Tracker> get mockWeekHistory {
    return [
      Tracker(date: DateTime.now().subtract(const Duration(days: 6)), steps: 7342, distance: 5.9),
      Tracker(date: DateTime.now().subtract(const Duration(days: 5)), steps: 8231, distance: 6.6),
      Tracker(date: DateTime.now().subtract(const Duration(days: 4)), steps: 6543, distance: 5.2),
      Tracker(date: DateTime.now().subtract(const Duration(days: 3)), steps: 9876, distance: 7.9),
      Tracker(date: DateTime.now().subtract(const Duration(days: 2)), steps: 4321, distance: 3.5),
      Tracker(date: DateTime.now().subtract(const Duration(days: 1)), steps: 5678, distance: 4.5),
      Tracker(date: DateTime.now(), steps: 5432, distance: 4.3),
    ];
  }

    // Личные челленджи
  static List<Challenge> get mockPersonalChallenges {
    return [
      Challenge(
        id: 'personal-1',
        title: '10 000 шагов',
        description: 'Проходи 10 000 шагов каждый день',
        goalSteps: 10000,
        progress: 5432,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        status: ChallengeStatus.active,
        type: ChallengeType.personal,
      ),
      Challenge(
        id: 'personal-2',
        title: 'Марафон 42 км',
        description: 'Пробежать марафон за неделю',
        goalSteps: 55000,
        progress: 23400,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        status: ChallengeStatus.active,
        type: ChallengeType.personal,
      ),
      Challenge(
        id: 'personal-3',
        title: 'Цель месяца',
        description: '300 000 шагов за месяц',
        goalSteps: 300000,
        progress: 45000,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        status: ChallengeStatus.active,
        type: ChallengeType.personal,
      ),
       Challenge(
        id: 'personal-4',
        title: 'Самый жесткий челлендж',
        description: '1 000 000 за пол года',
        goalSteps: 1000000,
        progress: 0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        status: ChallengeStatus.notStarted,
        type: ChallengeType.personal,
      ),
    ];
  }

  // Парные челленджи
  static List<Challenge> get mockPairedChallenges {
    return [
      Challenge(
        id: 'paired-1',
        title: 'Вдвоем веселее',
        description: 'Суммарно 50 000 шагов с другом',
        goalSteps: 50000,
        progress: 32400,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        status: ChallengeStatus.active,
        type: ChallengeType.paired,
        participantId: 'friend-1',
      ),
      Challenge(
        id: 'paired-2',
        title: 'Командный забег',
        description: 'Каждый по 30 000 шагов',
        goalSteps: 60000,
        progress: 15600,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        status: ChallengeStatus.active,
        type: ChallengeType.paired,
        participantId: 'friend-2',
      ),
    ];
  }

  // Завершенные челленжди
  static List<Challenge> get mockCompletedChallenges {
    return [
      Challenge(
        id: 'completed-1',
        title: 'Первый рубеж',
        description: '10 000 шагов за день',
        goalSteps: 10000,
        progress: 10000,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 9)),
        status: ChallengeStatus.completed,
        type: ChallengeType.personal,
      ),
      Challenge(
        id: 'completed-2',
        title: 'Неделя здоровья',
        description: '70 000 шагов за неделю',
        goalSteps: 70000,
        progress: 70000,
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        endDate: DateTime.now().subtract(const Duration(days: 13)),
        status: ChallengeStatus.completed,
        type: ChallengeType.personal,
      ),
    ];
  }

  static List<Challenge> get mockAllChallenges {
    return [
      ...mockPersonalChallenges,
      ...mockPairedChallenges,
      ...mockCompletedChallenges,
    ];
  }
}
