import 'package:dio/dio.dart';
import '../models/exercise_model.dart';
import '../../domain/entities/exercise_entity.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://wger.de/api/v2',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  Future<List<ExerciseModel>> fetchExercises(MuscleGroup group) async {
    final response = await _dio.get(
      '/exerciseinfo/',
      queryParameters: {
        'format': 'json',
        'language': 2,
        'category': group.apiCategoryId,
        'limit': 20,
        'offset': 0,
      },
    );

    final results = response.data['results'] as List;
    return results
        .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
        .where((m) => m.name.isNotEmpty && !m.name.startsWith('Exercise '))
        .toList();
  }
}