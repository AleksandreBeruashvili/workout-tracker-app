import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/services/api_service.dart';
import 'data/repositories/exercise_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/firestore_user_exercise_repository.dart';
import 'presentation/cubits/exercise_cubit.dart';
import 'presentation/cubits/auth_cubit.dart';
import 'presentation/cubits/auth_state.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(AuthRepositoryImpl())),
      ],
      child: MaterialApp(
        title: 'Workout Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

/// Switches between LoginScreen and HomeScreen based on Firebase auth state.
///
/// HomeScreen's ExerciseCubit is created here (not in main()) because it
/// depends on the signed-in user's uid, which only exists once
/// AuthAuthenticated is reached.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocProvider(
            create: (_) => ExerciseCubit(
              ExerciseRepositoryImpl(ApiService()),
              FirestoreUserExerciseRepository(uid: state.user.uid),
            ),
            child: const HomeScreen(),
          );
        }
        if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginScreen();
        }
        // AuthInitial / AuthLoading: waiting for the first auth event.
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
