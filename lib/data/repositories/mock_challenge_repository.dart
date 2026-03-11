import '../domain_models/challenge.dart';
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
}