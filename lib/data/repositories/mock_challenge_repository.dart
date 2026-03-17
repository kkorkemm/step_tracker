import '../domain_models/challenge.dart';
// ignore: unused_import
import '../enumerations/challenge_status.dart';
// ignore: unused_import
import '../enumerations/challenge_type.dart';
import '../mocks/mock_data.dart';
import 'challenge_repository.dart'; // импортируем интерфейс

class MockChallengeRepository implements ChallengeRepository {
  @override
  Future<Challenge?> getActiveChallenge() async {
    await Future.delayed(const Duration(seconds: 1));
    return MockData.mockChallenge;
  }

  @override
  Future<void> saveChallenge(Challenge challenge) async {
    print('Мок: сохранён челлендж ${challenge.title}');
  }

  @override
  Future<void> updateProgress(int additionalSteps) async {
    print('Мок: обновлён прогресс на +$additionalSteps');
  }

  @override
  Future<void> createTestChallenge() async {
    print('Мок: создан тестовый челлендж');
  }

  // Получить все челленджи
  Future<List<Challenge>> getAllChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    return MockData.mockAllChallenges;
  }

  // Получить активный челлендж (для главного экрана)
  @override
  Future<Challenge?> getActiveChallenge() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Возвращаем первый активный личный челлендж
    return MockData.mockPersonalChallenges.firstWhere(
      (c) => c.status == ChallengeStatus.active,
      orElse: () => MockData.mockPersonalChallenges.first,
    );
  }

  // Получить личные челленджи
  Future<List<Challenge>> getPersonalChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.mockPersonalChallenges;
  }

  // Получить парные челленджи
  Future<List<Challenge>> getPairedChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.mockPairedChallenges;
  }

  // Получить завершённые челленджи
  Future<List<Challenge>> getCompletedChallenges() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockData.mockCompletedChallenges;
  }
}
