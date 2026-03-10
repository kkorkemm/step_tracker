class Tracker {
  final DateTime date;
  final int steps;
  final double distance; // в километрах

  const Tracker({
    required this.date,
    required this.steps,
    required this.distance,
  });

  // Процент от цели (цель 10000 шагов)
  double get progressPercentage => (steps / 10000).clamp(0.0, 1.0);

  // Средний темп (мин/км) - условно
  double get averagePace {
    if (distance == 0) return 0;
    return 12.0 / distance; // 12 часов активности
  }

  // Проверка достижения цели
  bool isGoalReached(int goal) => steps >= goal;

  @override
  String toString() => 'Tracker: $steps шагов, $distance км';
}