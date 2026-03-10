import '../domain_models/challenge.dart';
import '../enumerations/challenge_status.dart';
import '../enumerations/challenge_type.dart';
import '../mocks/mock_data.dart';

class MockChallengeRepository {
  // Имитация загрузки
  Future<Challenge?> getActiveChallenge() async {
    await Future.delayed(const Duration(seconds: 1)); // имитация загрузки
    return MockData.mockActiveChallenge;
  }
  
  Future<void> createTestChallenge() async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Мок-челлендж создан');
  }
  
  // Для тестирования пустого состояния
  Future<Challenge?> getEmptyChallenge() async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }
  
  // Для тестирования ошибки
  Future<Challenge?> getErrorChallenge() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Ошибка загрузки челленджа');
  }
}