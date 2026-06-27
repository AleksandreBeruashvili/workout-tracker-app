import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/i_user_exercise_repository.dart';

/// Stores each user's custom exercises in:
///   users/{uid}/exercises/{docId}
///
/// Scoping by uid keeps one user's custom exercises private to them under
/// the test-mode rules, and is also exactly the structure you'd want once
/// rules are tightened to `if request.auth.uid == uid`.
class FirestoreUserExerciseRepository implements IUserExerciseRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreUserExerciseRepository({
    required String uid,
    FirebaseFirestore? firestore,
  })  : _uid = uid,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('exercises');

  @override
  Stream<List<ExerciseEntity>> watchUserExercises() {
    return _collection.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(_fromDoc).toList(),
        );
  }

  @override
  Future<void> addExercise(ExerciseEntity exercise) async {
    await _collection.add({
      'name': exercise.name,
      'description': exercise.description,
      'muscleGroup': exercise.muscleGroup.name,
      'equipment': exercise.equipment.name,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'duration': exercise.duration,
      'isCompleted': exercise.isCompleted,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteExercise(ExerciseEntity exercise) async {
    final docId = exercise.docId;
    if (docId == null) return;
    await _collection.doc(docId).delete();
  }

  @override
  Future<void> setCompleted(ExerciseEntity exercise, bool isCompleted) async {
    final docId = exercise.docId;
    if (docId == null) return;
    await _collection.doc(docId).update({'isCompleted': isCompleted});
  }

  ExerciseEntity _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ExerciseEntity(
      // Local numeric id is only used for ValueKey/UI purposes here;
      // the real identity for Firestore operations is docId below.
      id: -doc.id.hashCode.abs(),
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      muscleGroup: MuscleGroup.values.firstWhere(
        (g) => g.name == data['muscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      equipment: Equipment.values.firstWhere(
        (e) => e.name == data['equipment'],
        orElse: () => Equipment.bodyweight,
      ),
      sets: (data['sets'] as num?)?.toInt() ?? 3,
      reps: (data['reps'] as num?)?.toInt() ?? 12,
      duration: data['duration'] as String? ?? '',
      isFromApi: false,
      isCompleted: data['isCompleted'] as bool? ?? false,
      docId: doc.id,
    );
  }
}
