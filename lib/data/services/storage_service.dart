// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain_models/challenge.dart';
// ignore: unused_import
import '../domain_models/tracker.dart';
import '../domain_models/streak.dart';
import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';

class StorageService {
  static const String _stepsBox = 'steps';
  static const String _challengeBox = 'challenges';
  static const String _streakBox = 'streak';

  // Инициализация Hive
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<int>(_stepsBox);
    await Hive.openBox<Map>(_challengeBox);
    await Hive.openBox<Map>(_streakBox);
    print('Hive инициализирован');
  }

  // ---------- Работа со стриком ----------
  Future<void> saveStreak(Streak streak) async {
    final box = Hive.box<Map>(_streakBox);
    await box.put('streak', {
      'currentStreak': streak.currentStreak,
      'longestStreak': streak.longestStreak,
      'lastActiveDay': streak.lastActiveDay.toIso8601String(),
      'isActive': streak.isActive,
    });
    print('Стрик сохранён: ${streak.currentStreak} дней');
  }

  Future<Streak> getStreak() async {
    final box = Hive.box<Map>(_streakBox);
    final data = box.get('streak');

    if (data == null) {
      return Streak.empty();
    }

    try {
      return Streak(
        currentStreak: data['currentStreak'] ?? 0,
        longestStreak: data['longestStreak'] ?? 0,
        lastActiveDay: DateTime.parse(data['lastActiveDay']),
        isActive: data['isActive'] ?? false,
      );
    } catch (e) {
      print('Ошибка при чтении стрика: $e');
      return Streak.empty();
    }
  }

  Future<void> saveTodaySteps(int steps) async {
    final box = Hive.box<int>(_stepsBox);
    final today = _getTodayKey();
    await box.put(today, steps);
    
    final streak = await getStreak();
    final updatedStreak = streak.updateWithSteps(steps, 10000); // цель 10000 шагов
    await saveStreak(updatedStreak);
    
    print('Сохранено: $today = $steps шагов');
  }

  // Метод для сброса шагов за сегодня (для тестовой кнопки)
  Future<void> resetTodaySteps() async {
    final box = Hive.box<int>(_stepsBox);
    final today = _getTodayKey();
    await box.put(today, 0);
    
    // Пересчитываем стрик
    final streak = await getStreak();
    final updatedStreak = streak.updateWithSteps(0, 10000);
    await saveStreak(updatedStreak);
    
    print('Шаги за сегодня сброшены');
  }

  // ---------- Работа с шагами ----------

  Future<int> getTodaySteps() async {
    final box = Hive.box<int>(_stepsBox);
    final today = _getTodayKey();
    return box.get(today) ?? 0;
  }

  // ---------- Работа с челленджами ----------
  Future<void> saveActiveChallenge(Challenge challenge) async {
    final box = Hive.box<Map>(_challengeBox);
    await box.put('active', {
      'id': challenge.id,
      'title': challenge.title,
      'description': challenge.description,
      'goalSteps': challenge.goalSteps,
      'progress': challenge.progress,
      'startDate': challenge.startDate.toIso8601String(),
      'endDate': challenge.endDate?.toIso8601String(),
      'status': challenge.status.toString(),
      'type': challenge.type.toString(),
      'participantId': challenge.participantId,
    });
    print('Челлендж сохранён: ${challenge.title}');
  }

  Future<Challenge?> getActiveChallenge() async {
    final box = Hive.box<Map>(_challengeBox);
    final data = box.get('active');

    if (data == null) return null;

    try {
      return Challenge(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        goalSteps: data['goalSteps'],
        progress: data['progress'],
        startDate: DateTime.parse(data['startDate']),
        endDate: data['endDate'] != null ? DateTime.parse(data['endDate']) : null,
        status: _parseStatus(data['status']),
        type: _parseType(data['type']),
        participantId: data['participantId'],
      );
    } catch (e) {
      print('Ошибка при чтении челленджа: $e');
      return null;
    }
  }

  Future<void> updateChallengeProgress(int additionalSteps) async {
    final challenge = await getActiveChallenge();
    if (challenge == null) return;

    final updated = challenge.copyWith(
      progress: challenge.progress + additionalSteps,
      status: challenge.progress + additionalSteps >= challenge.goalSteps
          ? ChallengeStatus.completed
          : challenge.status,
    );

    await saveActiveChallenge(updated);
  }

  // ---------- Вспомогательные методы ----------
  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  ChallengeStatus _parseStatus(String statusString) {
    if (statusString.contains('active')) return ChallengeStatus.active;
    if (statusString.contains('completed')) return ChallengeStatus.completed;
    if (statusString.contains('failed')) return ChallengeStatus.failed;
    return ChallengeStatus.notStarted;
  }

  ChallengeType _parseType(String typeString) {
    if (typeString.contains('personal')) return ChallengeType.personal;
    return ChallengeType.paired;
  }

  // Очистить все данные (для тестирования)
  Future<void> clearAll() async {
    final stepsBox = Hive.box<int>(_stepsBox);
    final challengeBox = Hive.box<Map>(_challengeBox);
    final streakBox = Hive.box<Map>(_streakBox);
    
    await stepsBox.clear();
    await challengeBox.clear();
    await streakBox.clear();
    
    print('Все данные очищены');
  }
}