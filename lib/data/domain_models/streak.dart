class Streak {
  final int currentStreak;      // текущая серия дней
  final int longestStreak;      // рекордная серия
  final DateTime lastActiveDay; // последний день, когда была активность
  final bool isActive;          // активна ли серия сегодня

  const Streak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDay,
    required this.isActive,
  });

  // Создать пустой стрик (для первого запуска)
  factory Streak.empty() {
    return Streak(
      currentStreak: 0,
      longestStreak: 0,
      lastActiveDay: DateTime.now().subtract(const Duration(days: 1)),
      isActive: false,
    );
  }

  // Обновить стрик на основе новых шагов
  Streak updateWithSteps(int steps, int goalSteps) {
    final today = DateTime.now();
    final wasYesterday = lastActiveDay.day == today.subtract(const Duration(days: 1)).day;
    
    // Если выполнил цель сегодня
    if (steps >= goalSteps) {
      // Если вчера тоже выполнил - увеличиваем серию
      if (wasYesterday) {
        final newStreak = currentStreak + 1;
        return Streak(
          currentStreak: newStreak,
          longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
          lastActiveDay: today,
          isActive: true,
        );
      } else {
        // Начинаем новую серию
        return Streak(
          currentStreak: 1,
          longestStreak: longestStreak,
          lastActiveDay: today,
          isActive: true,
        );
      }
    }
    
    // Если цель не выполнена - серия прерывается (кроме сегодня)
    if (today.day != lastActiveDay.day) {
      return Streak(
        currentStreak: 0,
        longestStreak: longestStreak,
        lastActiveDay: lastActiveDay,
        isActive: false,
      );
    }
    
    return this;
  }

  Streak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDay,
    bool? isActive,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      isActive: isActive ?? this.isActive,
    );
  }
}