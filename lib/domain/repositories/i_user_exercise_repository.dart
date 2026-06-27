import '../entities/exercise_entity.dart';

/// Manages exercises created by the signed-in user (separate from the
/// read-only API-sourced exercises in [IExerciseRepository]).
abstract class IUserExerciseRepository {
  /// Live stream of the current user's custom exercises.
  Stream<List<ExerciseEntity>> watchUserExercises();

  Future<void> addExercise(ExerciseEntity exercise);

  Future<void> deleteExercise(ExerciseEntity exercise);

  Future<void> setCompleted(ExerciseEntity exercise, bool isCompleted);
}
