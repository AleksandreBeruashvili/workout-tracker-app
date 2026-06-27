import '../../domain/entities/exercise_entity.dart';

class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final List<String> equipmentNames;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.equipmentNames,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>;
    final categoryId = category['id'] as int;

    final translations = (json['translations'] as List?) ?? [];
    final enTranslation = translations.firstWhere(
          (t) {
        final lang = t['language'];
        if (lang is Map) return lang['id'] == 2;
        return lang == 2;
      },
      orElse: () => translations.isNotEmpty ? translations.first : <String, dynamic>{},
    );

    final name = ((enTranslation['name'] as String?) ?? '').trim();
    final rawDesc = (enTranslation['description'] as String?) ?? '';
    final description = _stripHtml(rawDesc).trim();

    final equipmentList = (json['equipment'] as List?) ?? [];
    final equipmentNames = equipmentList
        .map((e) => (e['name'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    return ExerciseModel(
      id: json['id'] as int,
      name: name.isEmpty ? 'Exercise ${json['id']}' : name,
      description: description.isEmpty ? 'No description available.' : description,
      categoryId: categoryId,
      equipmentNames: equipmentNames,
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  ExerciseEntity toEntity() {
    return ExerciseEntity(
      id: id,
      name: name,
      description: description,
      muscleGroup: _mapCategory(categoryId),
      equipment: _mapEquipment(equipmentNames),
      sets: 3,
      reps: 12,
      duration: '30 min',
      isFromApi: true,
    );
  }

  MuscleGroup _mapCategory(int catId) {
    return MuscleGroup.values.firstWhere(
          (g) => g.apiCategoryId == catId,
      orElse: () => MuscleGroup.chest,
    );
  }

  Equipment _mapEquipment(List<String> names) {
    if (names.isEmpty) return Equipment.bodyweight;
    final lower = names.first.toLowerCase();
    if (lower.contains('barbell') || lower.contains('bar')) return Equipment.barbell;
    if (lower.contains('dumbbell') || lower.contains('kettlebell')) return Equipment.dumbbell;
    if (lower.contains('machine') || lower.contains('cable')) return Equipment.machine;
    return Equipment.bodyweight;
  }
}