import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';

class DetailScreen extends StatelessWidget {
  final ExerciseEntity exercise;
  const DetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final color = exercise.muscleGroup.color;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // Hero animation — shared element with home screen icon
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(exercise.muscleGroup.icon,
                        size: 160, color: Colors.white.withOpacity(0.08)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          style: IconButton.styleFrom(backgroundColor: Colors.white12),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            exercise.muscleGroup.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exercise.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(icon: Icons.repeat, value: '${exercise.sets}', label: 'Sets', color: color)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(icon: Icons.loop, value: '${exercise.reps}', label: 'Reps', color: color)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard(icon: Icons.timer_outlined, value: exercise.duration, label: 'Duration', color: color)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: exercise.equipment.color.withOpacity(0.15),
                      border: Border.all(color: exercise.equipment.color.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sports_gymnastics, size: 16, color: exercise.equipment.color),
                        const SizedBox(width: 6),
                        Text(exercise.equipment.label,
                            style: TextStyle(color: exercise.equipment.color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      border: Border.all(color: color.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, color: color, size: 20),
                        const SizedBox(width: 12),
                        Expanded(child: Text(exercise.description, style: const TextStyle(height: 1.6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }
}