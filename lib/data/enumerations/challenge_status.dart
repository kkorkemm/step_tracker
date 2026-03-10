enum ChallengeStatus {
  active,
  completed,
  failed,
  notStarted;

  @override
  String toString() {
    switch (this) {
      case ChallengeStatus.active:
        return 'Активен';
      case ChallengeStatus.completed:
        return 'Завершён';
      case ChallengeStatus.failed:
        return 'Провален';
      case ChallengeStatus.notStarted:
        return 'Не начат';
    }
  }
}