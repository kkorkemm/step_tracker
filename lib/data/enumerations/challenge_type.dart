enum ChallengeType {
  personal,
  paired;

  @override
  String toString() {
    switch (this) {
      case ChallengeType.personal:
        return 'Личный';
      case ChallengeType.paired:
        return 'Парный';
    }
  }
}