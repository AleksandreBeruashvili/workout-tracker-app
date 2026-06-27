import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';

class AddScreen extends StatefulWidget {
  final MuscleGroup defaultGroup;
  const AddScreen({super.key, required this.defaultGroup});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _durationController = TextEditingController();
  final _descController = TextEditingController();

  late MuscleGroup _selectedGroup;
  Equipment _selectedEquipment = Equipment.bodyweight;

  @override
  void initState() {
    super.initState();
    _selectedGroup = widget.defaultGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final sets = int.tryParse(_setsController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final duration = _durationController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty || sets == null || reps == null || duration.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    Navigator.of(context).pop(ExerciseEntity(
      id: 0,
      name: name,
      description: description,
      muscleGroup: _selectedGroup,
      equipment: _selectedEquipment,
      sets: sets,
      reps: reps,
      duration: duration,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final color = _selectedGroup.color;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        centerTitle: true,
        backgroundColor: color.withOpacity(0.15),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (e.g. 30 min)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description / Tips', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text('Muscle Group', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values.map((g) {
                final selected = g == _selectedGroup;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGroup = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? g.color : g.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? g.color : g.color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(g.icon, size: 16, color: selected ? Colors.white : g.color),
                        const SizedBox(width: 6),
                        Text(g.label,
                            style: TextStyle(
                                color: selected ? Colors.white : g.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text('Equipment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Equipment.values.map((eq) {
                final selected = eq == _selectedEquipment;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEquipment = eq),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? eq.color : eq.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? eq.color : eq.color.withOpacity(0.3)),
                    ),
                    child: Text(eq.label,
                        style: TextStyle(
                            color: selected ? Colors.white : eq.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: const Text('Save Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}