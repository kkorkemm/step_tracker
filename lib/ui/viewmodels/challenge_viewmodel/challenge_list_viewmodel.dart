import 'package:flutter/material.dart';
import '../../../data/domain_models/challenge.dart';
import '../../../data/repositories/mock_challenge_repository.dart';
import '../../../data/mocks/mock_data.dart';
import '../../../data/enumerations/challenge_type.dart';
import '../../../data/enumerations/challenge_status.dart';

enum ChallengeTab { personal, paired, completed }

class ChallengeState {
  final ChallengeTab currentTab;
  final List<Challenge> personalChallenges;
  final List<Challenge> pairedChallenges;
  final List<Challenge> completedChallenges;
  final bool isLoading;
  final String? errorMessage;
  final Challenge? activeChallenge;
  final Challenge? selectedChallenge;

  ChallengeState({
    this.currentTab = ChallengeTab.personal,
    this.personalChallenges = const [],
    this.pairedChallenges = const [],
    this.completedChallenges = const [],
    this.isLoading = false,
    this.errorMessage,
    this.activeChallenge,
    this.selectedChallenge
  });

  ChallengeState copyWith({
    ChallengeTab? currentTab,
    List<Challenge>? personalChallenges,
    List<Challenge>? pairedChallenges,
    List<Challenge>? completedChallenges,
    bool? isLoading,
    String? errorMessage, 
    Challenge? activeChallenge,
    Challenge? selectedChallenge
  }) {
    return ChallengeState(
      currentTab: currentTab ?? this.currentTab,
      personalChallenges: personalChallenges ?? this.personalChallenges,
      pairedChallenges: pairedChallenges ?? this.pairedChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge
    );
  }

  // Текущий список в зависимости от выбранной вкладки
  List<Challenge> get currentChallenges {
    switch (currentTab) {
      case ChallengeTab.personal:
        return personalChallenges;
      case ChallengeTab.paired:
        return pairedChallenges;
      case ChallengeTab.completed:
        return completedChallenges;
    }
  }

  Object? get currentList => null;
}

class ChallengeViewModel extends ChangeNotifier {
  final MockChallengeRepository _challengeRepository;

  ChallengeState _state = ChallengeState(isLoading: true);
  ChallengeState get state => _state;

  ChallengeViewModel({required MockChallengeRepository challengeRepository})
      : _challengeRepository = challengeRepository {
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Загружаем все категории параллельно
      final results = await Future.wait([
        _challengeRepository.getPersonalChallenges(),
        _challengeRepository.getPairedChallenges(),
        _challengeRepository.getCompletedChallenges(),
      ]);

      _state = _state.copyWith(
        personalChallenges: results[0],
        pairedChallenges: results[1],
        completedChallenges: results[2],
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Ошибка загрузки: $e',
      );
    }

    notifyListeners();
  }

  // Переключение вкладки
  void changeTab(ChallengeTab tab) {
    if (_state.currentTab == tab) return;
    _state = _state.copyWith(currentTab: tab);
    notifyListeners();
  }

  // Обновить данные
  Future<void> refresh() async {
    await _loadChallenges();
  }
  void _loadData() {
    _state = _state.copyWith(
      personalChallenges: MockData.mockPersonalChallenges,
      pairedChallenges: MockData.mockPairedChallenges,
      completedChallenges: MockData.mockCompletedChallenges,
      activeChallenge: MockData.mockPersonalChallenges.first,
      isLoading: false,
    );
    notifyListeners();
  }


  void backToList() {
    _state = _state.copyWith(selectedChallenge: null);
    notifyListeners();
  }


void selectChallenge(Challenge challenge) {
  _state = _state.copyWith(selectedChallenge: challenge);
  notifyListeners();
}

void startChallenge(Challenge challenge) {
  final startedChallenge = challenge.copyWith(
    status: ChallengeStatus.active,
    startDate: DateTime.now(),
  );
  
  _state = _state.copyWith(
    activeChallenge: startedChallenge,
    selectedChallenge: null,  // закрываем детали
  );
  notifyListeners();
  
  // Здесь можно добавить сохранение в репозиторий
  print('Челлендж начат: ${challenge.title}');
  
}
}
