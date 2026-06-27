import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/services/api_service.dart';
import 'data/repositories/exercise_repository_impl.dart';
import 'presentation/cubits/exercise_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() => runApp(const WorkoutApp());

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExerciseCubit(
        ExerciseRepositoryImpl(ApiService()),
      ),
      child: MaterialApp(
        title: 'Workout Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}