import 'package:equatable/equatable.dart';
import '../../domain/entities/exercise_entity.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<ExerciseEntity> apiExercises;
  final List<ExerciseEntity> userExercises;
  final MuscleGroup selectedGroup;
  final String searchQuery;

  const ExerciseLoaded({
    required this.apiExercises,
    required this.userExercises,
    required this.selectedGroup,
    this.searchQuery = '',
  });

  List<ExerciseEntity> get allExercises => [...apiExercises, ...userExercises];

  List<ExerciseEntity> get filtered => allExercises.where((e) {
    return e.muscleGroup == selectedGroup &&
        e.name.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();

  int get completedInGroup =>
      allExercises.where((e) => e.muscleGroup == selectedGroup && e.isCompleted).length;

  int get totalInGroup =>
      allExercises.where((e) => e.muscleGroup == selectedGroup).length;

  int get totalCompleted => allExercises.where((e) => e.isCompleted).length;

  ExerciseLoaded copyWith({
    List<ExerciseEntity>? apiExercises,
    List<ExerciseEntity>? userExercises,
    MuscleGroup? selectedGroup,
    String? searchQuery,
  }) {
    return ExerciseLoaded(
      apiExercises: apiExercises ?? this.apiExercises,
      userExercises: userExercises ?? this.userExercises,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [apiExercises, userExercises, selectedGroup, searchQuery];
}

class ExerciseError extends ExerciseState {
  final String message;
  const ExerciseError(this.message);
  @override
  List<Object?> get props => [message];
}