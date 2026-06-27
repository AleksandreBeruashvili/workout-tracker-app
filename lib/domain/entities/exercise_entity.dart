import 'package:flutter/material.dart';

enum MuscleGroup {
  chest(label: 'Chest', icon: Icons.fitness_center, color: Color(0xFFFF5722), apiCategoryId: 10),
  back(label: 'Back', icon: Icons.accessibility_new, color: Color(0xFF2196F3), apiCategoryId: 11),
  legs(label: 'Legs', icon: Icons.directions_run, color: Color(0xFF4CAF50), apiCategoryId: 9),
  arms(label: 'Arms', icon: Icons.sports_martial_arts, color: Color(0xFF9C27B0), apiCategoryId: 8),
  core(label: 'Core', icon: Icons.self_improvement, color: Color(0xFFFFC107), apiCategoryId: 14);

  final String label;
  final IconData icon;
  final Color color;
  final int apiCategoryId;

  const MuscleGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.apiCategoryId,
  });
}

enum Equipment {
  barbell(label: 'Barbell', color: Color(0xFFFF5722)),
  dumbbell(label: 'Dumbbell', color: Color(0xFFFFC107)),
  machine(label: 'Machine', color: Color(0xFF2196F3)),
  bodyweight(label: 'Bodyweight', color: Color(0xFF4CAF50));

  final String label;
  final Color color;
  const Equipment({required this.label, required this.color});
}

class ExerciseEntity {
  final int id;
  final String name;
  final String description;
  final MuscleGroup muscleGroup;
  final Equipment equipment;
  final int sets;
  final int reps;
  final String duration;
  final bool isFromApi;
  bool isCompleted;

  ExerciseEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.duration,
    this.isFromApi = false,
    this.isCompleted = false,
  });
}