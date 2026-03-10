import 'package:flutter/material.dart';
import '../../../data/domain_models/challenge.dart';
// ignore: unused_import
import '../../../data/domain_models/tracker.dart';
import '../../../data/repositories/tracker_repository.dart';
import '../../../data/repositories/challenge_repository.dart';

// Состояние главного экрана
class HomeState {
  final int todaySteps;
  final double todayDistance;
  final Challenge? activeChallenge;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.todaySteps = 0,
    this.todayDistance = 0,
    this.activeChallenge,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    int? todaySteps,
    double? todayDistance,
    Challenge? activeChallenge,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      todaySteps: todaySteps ?? this.todaySteps,
      todayDistance: todayDistance ?? this.todayDistance,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final TrackerRepository _trackerRepository;
  final ChallengeRepository _challengeRepository;

  HomeState _state = const HomeState(isLoading: true);
  HomeState get state => _state;

  HomeViewModel({
    required TrackerRepository trackerRepository,
    required ChallengeRepository challengeRepository,
  }) : _trackerRepository = trackerRepository,
       _challengeRepository = challengeRepository {
    _init();
  }

  // Инициализация при создании
  Future<void> _init() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Загружаем данные параллельно
      await Future.wait([
        _loadSteps(),
        _loadChallenge(),
      ]);

      // Подписываемся на обновления шагов
      _trackerRepository.stepStream.listen((steps) {
        _onStepsUpdated(steps);
      });

      _state = _state.copyWith(isLoading: false, error: null);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки: $e',
      );
    }

    notifyListeners();
  }

  // Загрузка шагов
  Future<void> _loadSteps() async {
    final record = await _trackerRepository.getTodayTracker();
    _state = _state.copyWith(
      todaySteps: record.steps,
      todayDistance: record.distance,
    );
  }

  // Загрузка челленджа
  Future<void> _loadChallenge() async {
    final challenge = await _challengeRepository.getActiveChallenge();
    _state = _state.copyWith(activeChallenge: challenge);
  }

  // Обновление при новых шагах
  void _onStepsUpdated(int steps) {
    _state = _state.copyWith(
      todaySteps: steps,
      todayDistance: steps * 0.0008,
    );
    notifyListeners();

    // Сохраняем шаги и обновляем прогресс челленджа
    _trackerRepository.saveSteps(steps);
    _challengeRepository.updateProgress(
      steps - _state.todaySteps, // разница с предыдущим значением
    );
  }

  // Обновить данные (pull-to-refresh)
  Future<void> refresh() async {
    await _loadSteps();
    await _loadChallenge();
  }

  // Создать тестовый челлендж
  Future<void> createTestChallenge() async {
    await _challengeRepository.createTestChallenge();
    await _loadChallenge();
  }

  // Добавить тестовые шаги
  void addTestSteps() {
    _onStepsUpdated(_state.todaySteps + 1000);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
