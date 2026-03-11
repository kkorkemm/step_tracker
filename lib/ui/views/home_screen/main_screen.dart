import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../viewmodels/home_viewmodel/main_screen_viewmodel.dart';
import '../../../data/domain_models/challenge.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/step_service.dart';
import '../../../data/repositories/tracker_repository.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return _buildErrorState(viewModel);
          }

          if (state.isEmpty) {
            return _buildEmptyState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCircularTracker(state),
                  const SizedBox(height: 24),
                  _buildStatsRow(state),
                  const SizedBox(height: 32),
                  
                  // Активный челлендж (только карточка, без заголовка)
                  if (state.activeChallenge != null) ...[
                    _buildActiveChallenge(state.activeChallenge!),
                  ],
                  
                  const SizedBox(height: 20),
                  _buildTestButtons(viewModel, context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularTracker(HomeState state) {
    final progress = state.todaySteps / 10000;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1 ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.todaySteps}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'шагов',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Стрик
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: state.streak.isActive ? Colors.orange[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: state.streak.isActive ? Colors.orange : Colors.grey,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.whatshot,
                  color: state.streak.isActive ? Colors.orange : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Стрик: ${state.streak.currentStreak} дней',
                  style: TextStyle(
                    color: state.streak.isActive ? Colors.orange : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.streak.longestStreak > state.streak.currentStreak) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(рекорд: ${state.streak.longestStreak})',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(HomeState state) {
    final calories = (state.todaySteps * 0.04).toInt();
    final hoursActive = (state.todaySteps / 1000).toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.local_fire_department,
          value: '$calories',
          label: 'ккал',
          color: Colors.orange,
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey[300],
        ),
        _buildStatItem(
          icon: Icons.map,
          value: state.todayDistance.toStringAsFixed(1),
          label: 'км',
          color: Colors.green,
        ),
        Container(
          height: 40,
          width: 1,
          color: Colors.grey[300],
        ),
        _buildStatItem(
          icon: Icons.access_time,
          value: hoursActive,
          label: 'часа',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChallenge(Challenge challenge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge.progress} / ${challenge.goalSteps}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${(challenge.progressPercentage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ИСПРАВЛЕНО: используем errorMessage
  Widget _buildErrorState(HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              viewModel.state.errorMessage ?? 'Неизвестная ошибка',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Нет данных. Начните ходить или создайте челлендж!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.createTestChallenge(),
              child: const Text('Создать тестовый челлендж'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons(HomeViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => viewModel.addTestSteps(),
                icon: const Icon(Icons.add),
                label: const Text('+1000'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => viewModel.resetSteps(),
                icon: const Icon(Icons.refresh),
                label: const Text('Сброс'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
          
        ),
        /*const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Очистить базу шагов
                  await Hive.deleteBoxFromDisk('steps');
                  await Hive.openBox<int>('steps');
                  final box = await Hive.openBox<int>('steps');
                  final today = DateTime.now().toIso8601String().split('T')[0];
                  await box.put(today, 0);
                  print("Удалена запись за сегодня");

                  await context.read<HomeViewModel>().refresh();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Шаги за сегодня очищены'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Очистить шаги за сегодня'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        */
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => viewModel.createTestChallenge(),
          child: const Text('Создать тестовый челлендж'),
        ),
      ],
    );
  }
}