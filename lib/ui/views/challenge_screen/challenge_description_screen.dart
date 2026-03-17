import 'package:flutter/material.dart';
import '../../../data/domain_models/challenge.dart';
import '../../../data/enumerations/challenge_type.dart';
import '../../../data/enumerations/challenge_status.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onStartChallenge;

  const ChallengeDetailScreen({
    super.key,
    required this.challenge,
    required this.onStartChallenge,
  });

  @override
  Widget build(BuildContext context) {
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
            _buildDetailRow('Тип', challenge.type == ChallengeType.personal ? 'Личный' : 'Парный'),
            const Divider(),
            _buildDetailRow(
              'Статус', 
              _getStatusText(challenge.status),
              color: _getStatusColor(challenge.status),
            ),
            
            if (challenge.progress > 0) ...[
              const Divider(),
              _buildDetailRow('Прогресс', '${challenge.progress} шагов'),
            ],
            
            const Spacer(),
            
            // Кнопка "Начать челлендж" (только если не начат)
            if (challenge.status == ChallengeStatus.notStarted)
              Center(
                child:  ElevatedButton.icon(
                onPressed: () => {},
                icon: const Icon(Icons.man_2),
                label: const Text('Бросить себе вызов!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              ),              
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ChallengeType type) {
    return type == ChallengeType.personal ? Colors.blue : Colors.purple;
  }

  IconData _getTypeIcon(ChallengeType type) {
    return type == ChallengeType.personal ? Icons.person : Icons.people;
  }

  String _getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.notStarted:
        return 'Не начат';
      case ChallengeStatus.active:
        return 'Активен';
      case ChallengeStatus.completed:
        return 'Завершён';
      case ChallengeStatus.failed:
        return 'Провален';
      default:
        return 'Неизвестно';
    }
  }

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.notStarted:
        return Colors.grey;
      case ChallengeStatus.active:
        return Colors.green;
      case ChallengeStatus.completed:
        return Colors.green;
      case ChallengeStatus.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
