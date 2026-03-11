import 'package:flutter/material.dart';
import '../../../data/domain_models/challenge.dart';
import '../../../data/domain_models/streak.dart';
// ignore: unused_import
import '../../../data/domain_models/tracker.dart';
import '../../../data/repositories/tracker_repository.dart';
import '../../../data/repositories/challenge_repository.dart';

// Состояние главного экрана
enum ViewState { loading, normal, empty, error }

class HomeState {
  final ViewState state;
  final int todaySteps;
  final double todayDistance;
  final Challenge? activeChallenge;
  final Streak streak;
  final String? errorMessage;
  HomeState({
    this.state = ViewState.loading,
    this.todaySteps = 0,
    this.todayDistance = 0,
    this.activeChallenge,
    required this.streak,
    this.errorMessage,
  });

  // Фабричный метод для начального состояния
  factory HomeState.initial() {
    return HomeState(
      state: ViewState.loading,
      streak: Streak.empty(),
    );
  }

  // Геттеры
  bool get isLoading => state == ViewState.loading;
  bool get isEmpty => state == ViewState.empty;
  bool get isError => state == ViewState.error;
  bool get isNormal => state == ViewState.normal;

  // copyWith метод
  HomeState copyWith({
    ViewState? state,
    int? todaySteps,
    double? todayDistance,
    Challenge? activeChallenge,
    Streak? streak,
    String? errorMessage,
  }) {
    return HomeState(
      state: state ?? this.state,
      todaySteps: todaySteps ?? this.todaySteps,
      todayDistance: todayDistance ?? this.todayDistance,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      streak: streak ?? this.streak,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final TrackerRepository _trackerRepository;
  final ChallengeRepository _challengeRepository;

  HomeState _state = HomeState.initial();
  HomeState get state => _state;

  HomeViewModel({
    required TrackerRepository trackerRepository,
    required ChallengeRepository challengeRepository,
  }) : _trackerRepository = trackerRepository,
       _challengeRepository = challengeRepository {
    _init();
  }

  Future<void> _loadStreak() async {
    final streak = await _trackerRepository.getStreak();
    _state = _state.copyWith(streak: streak);
  }

  Future<void> _init() async {
    _state = _state.copyWith(state: ViewState.loading);
    notifyListeners();

    try {
      await Future.wait([
        _loadSteps(),
        _loadChallenge(),
        _loadStreak(),
      ]);

      if (_state.todaySteps == 0 && _state.activeChallenge == null) {
        _state = _state.copyWith(state: ViewState.empty);
      } else {
        _state = _state.copyWith(state: ViewState.normal, errorMessage: null);
      }

      _trackerRepository.stepStream.listen((steps) {
        _onStepsUpdated(steps);
      });

    } catch (e) {
      _state = _state.copyWith(
        state: ViewState.error,
        errorMessage: 'Ошибка загрузки: $e',
      );
    }

    notifyListeners();
  }

  void _onStepsUpdated(int steps) async {
    _state = _state.copyWith(
      todaySteps: steps,
      todayDistance: steps * 0.0008,
      state: ViewState.normal,
    );
    notifyListeners();

    await _trackerRepository.saveSteps(steps);
    await _challengeRepository.updateProgress(
      steps - _state.todaySteps,
    );
    await _loadStreak();
  }

  Future<void> resetSteps() async {
    await _trackerRepository.resetTodaySteps();
    await _loadSteps();
    await _loadStreak();
    _state = _state.copyWith(state: ViewState.normal);
    notifyListeners();
  }

  Future<void> refresh() async {
    _state = _state.copyWith(state: ViewState.loading);
    notifyListeners();
    
    await Future.wait([
      _loadSteps(),
      _loadChallenge(),
      _loadStreak(),
    ]);
    
    _state = _state.copyWith(state: ViewState.normal);
    notifyListeners();
  }

  Future<void> _loadSteps() async {
    final record = await _trackerRepository.getTodayTracker();
    _state = _state.copyWith(
      todaySteps: record.steps,
      todayDistance: record.distance,
    );
  }

  Future<void> _loadChallenge() async {
    final challenge = await _challengeRepository.getActiveChallenge();
    _state = _state.copyWith(activeChallenge: challenge);
  }

  Future<void> createTestChallenge() async {
    await _challengeRepository.createTestChallenge();
    await _loadChallenge();
    _state = _state.copyWith(state: ViewState.normal);
    notifyListeners();
  }

  void addTestSteps() {
    _onStepsUpdated(_state.todaySteps + 1000);
  }

  @override
  void dispose() {
    super.dispose();
  }
}