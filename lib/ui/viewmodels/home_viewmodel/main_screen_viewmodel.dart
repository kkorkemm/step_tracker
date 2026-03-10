import 'package:flutter/material.dart';
import '../../../data/domain_models/challenge.dart';
import '../../../data/domain_models/streak.dart';
// ignore: unused_import
import '../../../data/domain_models/tracker.dart';
import '../../../data/repositories/tracker_repository.dart';
import '../../../data/repositories/challenge_repository.dart';

// Состояние главного экрана
class HomeState {
  final int todaySteps;
  final double todayDistance;
  final Challenge? activeChallenge;
  final Streak streak;
  final bool isLoading;
  final String? error;

  // Конструктор с правильной инициализацией
  HomeState({
    this.todaySteps = 0,
    this.todayDistance = 0,
    this.activeChallenge,
    Streak? streak,
    this.isLoading = false,
    this.error,
  }) : this.streak = streak ?? Streak.empty(); // ВЫЗОВ ПОСЛЕ ДВОЕТОЧИЯ

  // copyWith метод
  HomeState copyWith({
    int? todaySteps,
    double? todayDistance,
    Challenge? activeChallenge,
    Streak? streak,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      todaySteps: todaySteps ?? this.todaySteps,
      todayDistance: todayDistance ?? this.todayDistance,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final TrackerRepository _trackerRepository;
  final ChallengeRepository _challengeRepository;

  HomeState _state =  HomeState(isLoading: true);
  HomeState get state => _state;

  HomeViewModel({
    required TrackerRepository trackerRepository,
    required ChallengeRepository challengeRepository,
  }) : _trackerRepository = trackerRepository,
       _challengeRepository = challengeRepository {
    _init();
  }

 // Добавить метод для загрузки стрика
  Future<void> _loadStreak() async {
    final streak = await _trackerRepository.getStreak();
    _state = _state.copyWith(streak: streak);
  }

  // Обновить _init()
  Future<void> _init() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      await Future.wait([
        _loadSteps(),
        _loadChallenge(),
        _loadStreak(),                    // добавить загрузку стрика
      ]);

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

  // Обновить _onStepsUpdated
  void _onStepsUpdated(int steps) async {
    _state = _state.copyWith(
      todaySteps: steps,
      todayDistance: steps * 0.0008,
    );
    notifyListeners();

    // Сохраняем шаги (метод сам обновит стрик)
    await _trackerRepository.saveSteps(steps);
    
    // Обновляем прогресс челленджа
    await _challengeRepository.updateProgress(
      steps - _state.todaySteps,
    );
    
    // Перезагружаем стрик (он уже обновился в saveSteps)
    await _loadStreak();
  }

  Future<void> resetSteps() async {
    await _trackerRepository.resetTodaySteps();  // теперь сбрасывает и шагомер
    await _loadSteps();
    await _loadStreak();
  }

  // Обновить refresh()
  Future<void> refresh() async {
    await Future.wait([
      _loadSteps(),
      _loadChallenge(),
      _loadStreak(),
    ]);
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
