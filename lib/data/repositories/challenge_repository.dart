import '../domain_models/challenge.dart';
import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';
import '../services/storage_service.dart';

class ChallengeRepository {
  final StorageService _storage;

  ChallengeRepository({required StorageService storage}) : _storage = storage;

  // Получить активный челлендж
  Future<Challenge?> getActiveChallenge() async {
    return await _storage.getActiveChallenge();
  }

  // Сохранить челлендж
  Future<void> saveChallenge(Challenge challenge) async {
    await _storage.saveActiveChallenge(challenge);
  }

  // Обновить прогресс
  Future<void> updateProgress(int additionalSteps) async {
    await _storage.updateChallengeProgress(additionalSteps);
  }

  // Создать тестовый челлендж
  Future<void> createTestChallenge() async {
    final challenge = Challenge(
      id: 'ch_${DateTime.now().millisecondsSinceEpoch}',
      title: '10 000 шагов в день',
      description: 'Проходите 10 000 шагов каждый день и следите за прогрессом',
      goalSteps: 10000,
      progress: 0,
      startDate: DateTime.now(),
      status: ChallengeStatus.active,
      type: ChallengeType.personal,
    );
    await saveChallenge(challenge);
  }
}