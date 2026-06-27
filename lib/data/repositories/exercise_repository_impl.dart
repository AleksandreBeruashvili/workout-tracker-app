import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../services/api_service.dart';

class ExerciseRepositoryImpl implements IExerciseRepository {
  final ApiService _apiService;
  ExerciseRepositoryImpl(this._apiService);

  @override
  Future<List<ExerciseEntity>> getExercisesByCategory(MuscleGroup group) async {
    final models = await _apiService.fetchExercises(group);
    return models.map((m) => m.toEntity()).toList();
  }
}