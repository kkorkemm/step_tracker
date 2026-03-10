import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final int goalSteps;
  final int progress;
  final DateTime startDate;
  final DateTime? endDate;
  final ChallengeStatus status;
  final ChallengeType type;
  final String? participantId; // для парных челленджей - ID друга

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.goalSteps,
    required this.progress,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.type,
    this.participantId,
  });

  // Процент выполнения
  double get progressPercentage {
    if (goalSteps == 0) return 0;
    return (progress / goalSteps).clamp(0.0, 1.0);
  }

  // Активен ли
  bool get isActive => status == ChallengeStatus.active;

  // Завершён ли
  bool get isCompleted => status == ChallengeStatus.completed;

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
    );
  }
}