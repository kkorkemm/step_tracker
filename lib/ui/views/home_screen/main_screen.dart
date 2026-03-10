import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel/main_screen_viewmodel.dart';
import '../../../data/domain_models/challenge.dart';

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

          if (state.error != null) {
            return _buildErrorState(viewModel);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Круговой трекер
                  _buildCircularTracker(state),
                  const SizedBox(height: 24),
                  
                  // Статистика (калории, км, часы)
                  _buildStatsRow(state),
                  const SizedBox(height: 32),
                  
                  // Активный челлендж
                  if (state.activeChallenge != null) ...[
                    const Text(
                      'Активный челлендж',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActiveChallenge(state.activeChallenge!),
                  ],
                  
                  const SizedBox(height: 20),
                  _buildTestButtons(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircularTracker(HomeState state) {
    final progress = state.todaySteps / 10000; // цель 10000 шагов
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Круговой прогресс
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
              // Текст посередине
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
        ],
      ),
    );
  }

  Widget _buildStatsRow(HomeState state) {
    // Примерные расчёты
    final calories = (state.todaySteps * 0.04).toInt(); // 1 шаг ≈ 0.04 ккал
    final hoursActive = (state.todaySteps / 1000).toStringAsFixed(1); // условно

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
              viewModel.state.error!,
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

  Widget _buildTestButtons(HomeViewModel viewModel) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () => viewModel.addTestSteps(),
          icon: const Icon(Icons.add),
          label: const Text('Добавить 1000 шагов (тест)'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => viewModel.createTestChallenge(),
          child: const Text('Создать тестовый челлендж'),
        ),
      ],
    );
  }