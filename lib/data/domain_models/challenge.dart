import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int goalSteps;
  final int goalDays;
  final int progress;
  final DateTime startDate;
  final DateTime? endDate;
  final ChallengeStatus status;
  final ChallengeType type;
  final String? participantId; // для парных челленджей - ID друга         
  final int currentDay;
  final int pauseDaysLeft;
  final bool hasWarning;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.goalSteps,
    this.goalDays = 30,        // по умолчанию 30 дней
    this.progress = 0,
    this.currentDay = 0,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.type,
    this.pauseDaysLeft = 0,
    this.hasWarning = false,
    this.participantId = '1'
  });

  // Процент выполнения
  double get progressPercentage {
    if (goalSteps == 0) return 0;
    return (progress / goalSteps).clamp(0.0, 1.0);
  }

  // Процент выполнения по дням
  double get dayPercentage => (currentDay / goalDays).clamp(0.0, 1.0);
  
  bool get isActive => status == ChallengeStatus.active;
  bool get isPaused => status == ChallengeStatus.notStarted;
  bool get isCompleted => status == ChallengeStatus.completed;
  bool get isFailed => status == ChallengeStatus.failed;

  // Можно ли активировать паузу
  bool get canPause => isActive && pauseDaysLeft > 0;

  // Сколько дней осталось
  int get remainingDays {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  // Скопировать с изменениями
  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? goalSteps,
    int? progress,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    ChallengeType? type,
    String? participantId,
    int? currentDay,
    bool? hasWarning,
    int? pauseDaysLeft,
    int? goalDays
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      goalSteps: goalSteps ?? this.goalSteps,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      type: type ?? this.type,
      participantId: participantId ?? this.participantId,
      currentDay: currentDay ?? this.currentDay,
      goalDays: goalDays ?? this.goalDays,
      hasWarning: hasWarning ?? this.hasWarning,
      pauseDaysLeft: pauseDaysLeft ?? this.pauseDaysLeft
    );
  }
}
