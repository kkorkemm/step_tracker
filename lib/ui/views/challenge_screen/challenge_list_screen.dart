import 'package:flutter/material.dart';
import 'package:foot_crew/data/enumerations/challenge_status.dart';
import 'package:foot_crew/data/enumerations/challenge_type.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/challenge_viewmodel/challenge_list_viewmodel.dart';
import '../../../data/repositories/mock_challenge_repository.dart';
import '../../../data/domain_models/challenge.dart';
import 'challenge_description_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  const ChallengeListScreen({super.key});
  
  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChallengeViewModel(
        challengeRepository: MockChallengeRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Челленджи'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: _buildTabBar(),
        ),
        body: Consumer<ChallengeViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          // Если выбран конкретный челлендж - показываем детали
          if (state.selectedChallenge != null) {
            return _buildChallengeDetails(state.selectedChallenge!, viewModel);
          }

          // Иначе показываем список
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return _buildErrorState(viewModel);
          }

          if (state.currentChallenges.isEmpty) {
            return _buildEmptyState(viewModel.state.currentTab);
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.currentChallenges.length,
              itemBuilder: (context, index) {
                final challenge = state.currentChallenges[index];
                return _buildChallengeCard(context, challenge);
              },
            ),
          );
        },
),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        color: Colors.orange[700],
        child: Consumer<ChallengeViewModel>(
          builder: (context, viewModel, child) {
            return Row(
              children: [
                _buildTab(
                  title: 'Личные',
                  isSelected: viewModel.state.currentTab == ChallengeTab.personal,
                  onTap: () => viewModel.changeTab(ChallengeTab.personal),
                ),
                _buildTab(
                  title: 'Парные',
                  isSelected: viewModel.state.currentTab == ChallengeTab.paired,
                  onTap: () => viewModel.changeTab(ChallengeTab.paired),
                ),
                _buildTab(
                  title: 'Завершённые',
                  isSelected: viewModel.state.currentTab == ChallengeTab.completed,
                  onTap: () => viewModel.changeTab(ChallengeTab.completed),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, Challenge challenge) {
  final progress = challenge.progressPercentage;
  
  return GestureDetector(
    onTap: () {
      // Навигация на отдельный экран
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeDetailScreen(
            challenge: challenge,
            onStartChallenge: () {
              // Получаем ViewModel и начинаем челлендж
              final viewModel = context.read<ChallengeViewModel>();
              viewModel.startChallenge(challenge);
            },
          ),
        ),
      );
    },
    child: Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(challenge.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(challenge.type),
                    color: Colors.white,
                    size: 16,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progress),
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
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
                  '${(progress * 100).toStringAsFixed(0)}%',
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
    ),
  );
}

  Widget _buildChallengeDetails(Challenge challenge, ChallengeViewModel viewModel) {
  return Scaffold(
    appBar: AppBar(
      title: Text(challenge.title),
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка и тип
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getTypeColor(challenge.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(challenge.type),
                size: 64,
                color: _getTypeColor(challenge.type),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Название
          Center(
            child: Text(
              challenge.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Описание
          Center(
            child: Text(
              challenge.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Детали
          _buildDetailRow('Цель', '${challenge.goalSteps} шагов'),
          const Divider(),
          _buildDetailRow('Прогресс', '${challenge.progress} шагов'),
          const Divider(),
          _buildDetailRow('Статус', challenge.status.toString().split('.').last),
          
          const SizedBox(height: 32),
          
          // Кнопка "Начать челлендж" (только если не начат)
          if (challenge.status == ChallengeStatus.notStarted)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  viewModel.startChallenge(challenge);
                  Navigator.pop(context!); // Возвращаемся к списку
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Начать челлендж!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

  Color _getTypeColor(ChallengeType type) {
    switch (type) {
      case ChallengeType.personal:
        return Colors.blue;
      case ChallengeType.paired:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.personal:
        return Icons.person;
      case ChallengeType.paired:
        return Icons.people;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildErrorState(ChallengeViewModel viewModel) {
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

  Widget _buildEmptyState(ChallengeTab tab) {
    String message;
    switch (tab) {
      case ChallengeTab.personal:
        message = 'У вас нет личных челленджей';
        break;
      case ChallengeTab.paired:
        message = 'У вас нет парных челленджей';
        break;
      case ChallengeTab.completed:
        message = 'У вас нет завершённых челленджей';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
