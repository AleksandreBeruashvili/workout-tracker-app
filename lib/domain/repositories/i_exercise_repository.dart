import '../entities/exercise_entity.dart';

abstract class IExerciseRepository {
  Future<List<ExerciseEntity>> getExercisesByCategory(MuscleGroup group);
}