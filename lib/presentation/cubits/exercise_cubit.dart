import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../../domain/repositories/i_user_exercise_repository.dart';
import 'exercise_state.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final IExerciseRepository _repository;
  final IUserExerciseRepository _userRepository;
  StreamSubscription<List<ExerciseEntity>>? _userExercisesSubscription;

  ExerciseCubit(this._repository, this._userRepository) : super(ExerciseInitial()) {
    // Firestore stream keeps userExercises live-synced across the app
    // (and across devices, if the same account signs in elsewhere).
    _userExercisesSubscription = _userRepository.watchUserExercises().listen((userExercises) {
      final prev = state;
      if (prev is ExerciseLoaded) {
        emit(prev.copyWith(userExercises: userExercises));
      }
    });
  }

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

  Future<void> addUserExercise(ExerciseEntity exercise) async {
    // Optimistically just fire the write; the Firestore stream above will
    // emit the updated list (with a real docId) once it round-trips.
    await _userRepository.addExercise(exercise);
  }

  Future<void> deleteExercise(ExerciseEntity exercise) async {
    if (exercise.isFromApi) {
      final current = state;
      if (current is ExerciseLoaded) {
        emit(current.copyWith(
          apiExercises: current.apiExercises.where((e) => e.id != exercise.id).toList(),
        ));
      }
    } else {
      await _userRepository.deleteExercise(exercise);
    }
  }

  Future<void> toggleComplete(ExerciseEntity exercise) async {
    if (exercise.isFromApi) {
      final current = state;
      if (current is ExerciseLoaded) {
        final newApi = [...current.apiExercises];
        final idx = newApi.indexWhere((e) => e.id == exercise.id);
        if (idx != -1) newApi[idx].isCompleted = !newApi[idx].isCompleted;
        emit(current.copyWith(apiExercises: newApi));
      }
    } else {
      await _userRepository.setCompleted(exercise, !exercise.isCompleted);
    }
  }

  @override
  Future<void> close() {
    _userExercisesSubscription?.cancel();
    return super.close();
  }
}
