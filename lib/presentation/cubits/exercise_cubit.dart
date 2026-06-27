import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final IExerciseRepository _repository;
  int _userIdCounter = -1;

  ExerciseCubit(this._repository) : super(ExerciseInitial());

  Future<void> loadExercises(MuscleGroup group) async {
    final prev = state;
    final userExercises = prev is ExerciseLoaded ? prev.userExercises : <ExerciseEntity>[];
    emit(ExerciseLoading());
    try {
      final exercises = await _repository.getExercisesByCategory(group);
      emit(ExerciseLoaded(
        apiExercises: exercises,
        userExercises: userExercises,
        selectedGroup: group,
      ));
    } catch (e) {
      emit(const ExerciseError('Failed to load. Check your internet connection.'));
    }
  }

  void search(String query) {
    final current = state;
    if (current is ExerciseLoaded) emit(current.copyWith(searchQuery: query));
  }

  void addUserExercise(ExerciseEntity exercise) {
    final current = state;
    if (current is ExerciseLoaded) {
      final withId = ExerciseEntity(
        id: _userIdCounter--,
        name: exercise.name,
        description: exercise.description,
        muscleGroup: exercise.muscleGroup,
        equipment: exercise.equipment,
        sets: exercise.sets,
        reps: exercise.reps,
        duration: exercise.duration,
        isFromApi: false,
      );
      emit(current.copyWith(userExercises: [...current.userExercises, withId]));
    }
  }

  void deleteExercise(ExerciseEntity exercise) {
    final current = state;
    if (current is ExerciseLoaded) {
      if (exercise.isFromApi) {
        emit(current.copyWith(
          apiExercises: current.apiExercises.where((e) => e.id != exercise.id).toList(),
        ));
      } else {
        emit(current.copyWith(
          userExercises: current.userExercises.where((e) => e.id != exercise.id).toList(),
        ));
      }
    }
  }

  void toggleComplete(ExerciseEntity exercise) {
    final current = state;
    if (current is ExerciseLoaded) {
      final newApi = [...current.apiExercises];
      final newUser = [...current.userExercises];
      if (exercise.isFromApi) {
        final idx = newApi.indexWhere((e) => e.id == exercise.id);
        if (idx != -1) newApi[idx].isCompleted = !newApi[idx].isCompleted;
      } else {
        final idx = newUser.indexWhere((e) => e.id == exercise.id);
        if (idx != -1) newUser[idx].isCompleted = !newUser[idx].isCompleted;
      }
      emit(current.copyWith(apiExercises: newApi, userExercises: newUser));
    }
  }
}