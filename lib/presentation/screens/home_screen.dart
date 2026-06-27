import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/exercise_entity.dart';
import '../cubits/exercise_cubit.dart';
import '../cubits/exercise_state.dart';
import '../cubits/auth_cubit.dart';
import 'detail_screen.dart';
import 'add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Explicit animation — refresh button rotation
  late final AnimationController _refreshController;
  late final Animation<double> _refreshAnimation;

  // Explicit animation — list slide entrance
  late final AnimationController _listController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _refreshAnimation = CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut);

    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _listController, curve: Curves.easeOut));
    _fadeAnimation = CurvedAnimation(parent: _listController, curve: Curves.easeIn);

    context.read<ExerciseCubit>().loadExercises(MuscleGroup.chest);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _changeGroup(MuscleGroup group) {
    _refreshController.forward(from: 0);
    context.read<ExerciseCubit>().loadExercises(group);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ExerciseCubit, ExerciseState>(
          listener: (context, state) {
            if (state is ExerciseLoaded) _listController.forward(from: 0);
          },
          builder: (context, state) {
            if (state is ExerciseInitial || state is ExerciseLoading) {
              return _buildLoading();
            }
            if (state is ExerciseError) return _buildError(state.message);
            if (state is ExerciseLoaded) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return isWide ? _buildWide(state) : _buildNarrow(state);
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ── States ──────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.network(
            'https://assets4.lottiefiles.com/packages/lf20_qpwbiyxf.json',
            width: 200,
            errorBuilder: (_, __, ___) => const CircularProgressIndicator(),
          ),
          const SizedBox(height: 16),
          const Text('Loading exercises...', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets3.lottiefiles.com/packages/lf20_wnqlfojb.json',
              width: 180,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.wifi_off, size: 80, color: Colors.white24),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.read<ExerciseCubit>().loadExercises(MuscleGroup.chest),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Layouts ─────────────────────────────

  Widget _buildNarrow(ExerciseLoaded state) {
    return Column(
      children: [
        _buildHeader(state),
        _buildGroupTabs(state, horizontal: true),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSearchBar(),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildProgressSection(state),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(state)),
      ],
    );
  }

  Widget _buildWide(ExerciseLoaded state) {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: Column(
            children: [
              _buildHeader(state),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProgressSection(state),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildGroupTabs(state, horizontal: false)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSearchBar(),
              ),
              Expanded(child: _buildList(state)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Widgets ─────────────────────────────

  Widget _buildHeader(ExerciseLoaded state) {
    final color = state.selectedGroup.color;
    final total = state.allExercises.length;
    final done = state.totalCompleted;

    // Implicit animation — AnimatedContainer for color change
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.85), color.withOpacity(0.25)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Implicit animation — AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(state.selectedGroup.icon,
                    key: ValueKey(state.selectedGroup), color: Colors.white, size: 26),
              ),
              const SizedBox(width: 10),
              const Text('Workout Tracker',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Sign out',
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
              // Explicit animation — RotationTransition
              RotationTransition(
                turns: _refreshAnimation,
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _changeGroup(state.selectedGroup),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(value: '$total', label: 'Total'),
              const SizedBox(width: 20),
              _Stat(value: '$done', label: 'Done'),
              const SizedBox(width: 20),
              _Stat(
                value: total == 0 ? '0%' : '${(done / total * 100).round()}%',
                label: 'Progress',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTabs(ExerciseLoaded state, {required bool horizontal}) {
    final tabs = MuscleGroup.values.map((g) {
      final selected = state.selectedGroup == g;
      // Implicit animation — AnimatedContainer
      return GestureDetector(
        onTap: () => _changeGroup(g),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: horizontal
              ? const EdgeInsets.only(right: 10)
              : const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? g.color : g.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? g.color : g.color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: horizontal ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(g.icon, size: 18, color: selected ? Colors.white : g.color),
              const SizedBox(width: 8),
              Text(
                g.label,
                style: TextStyle(
                  color: selected ? Colors.white : g.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (horizontal) {
      return SizedBox(
        height: 64,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          children: tabs,
        ),
      );
    }
    return ListView(padding: const EdgeInsets.only(top: 12), children: tabs);
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => context.read<ExerciseCubit>().search(v),
      decoration: InputDecoration(
        hintText: 'Search exercise...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildProgressSection(ExerciseLoaded state) {
    final progress = state.totalInGroup == 0 ? 0.0 : state.completedInGroup / state.totalInGroup;
    final color = state.selectedGroup.color;
    return Column(
      children: [
        Row(
          children: [
            Text(state.selectedGroup.label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Text('${state.completedInGroup} / ${state.totalInGroup} done',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        // Implicit animation — TweenAnimationBuilder
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(ExerciseLoaded state) {
    final list = state.filtered;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie animation — empty state
            Lottie.network(
              'https://assets3.lottiefiles.com/packages/lf20_wnqlfojb.json',
              width: 180,
              errorBuilder: (_, __, ___) => Icon(
                state.selectedGroup.icon,
                size: 56,
                color: state.selectedGroup.color.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 12),
            const Text('No exercises found.', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    // Explicit animation — SlideTransition + FadeTransition for list entrance
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final ex = list[index];
            return Dismissible(
              key: ValueKey('${ex.id}_${ex.isFromApi}'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.only(right: 24),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) => context.read<ExerciseCubit>().deleteExercise(ex),
              child: _ExerciseCard(
                exercise: ex,
                onToggle: () => context.read<ExerciseCubit>().toggleComplete(ex),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetailScreen(exercise: ex)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFab() {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        if (state is! ExerciseLoaded) return const SizedBox();
        return FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push<ExerciseEntity>(
              MaterialPageRoute(
                builder: (_) => AddScreen(defaultGroup: state.selectedGroup),
              ),
            );
            if (result != null) context.read<ExerciseCubit>().addUserExercise(result);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Exercise'),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  const _ExerciseCard({required this.exercise, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = exercise.muscleGroup.color;
    final done = exercise.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: // Implicit animation — AnimatedContainer for completion state
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: done ? color.withOpacity(0.1) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: done ? color.withOpacity(0.6) : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 52,
                decoration: BoxDecoration(
                  color: done ? color : color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? color : color.withOpacity(0.12),
                    border: Border.all(
                      color: done ? color : color.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    done ? Icons.check : exercise.muscleGroup.icon,
                    color: done ? Colors.white : color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? Colors.white30 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _Badge(label: '${exercise.sets}s', icon: Icons.repeat),
                        const SizedBox(width: 6),
                        _Badge(label: '${exercise.reps}r', icon: Icons.loop),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: exercise.equipment.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: exercise.equipment.color.withOpacity(0.4)),
                          ),
                          child: Text(
                            exercise.equipment.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: exercise.equipment.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Badge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: Colors.white38),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ],
      ),
    );
  }
}