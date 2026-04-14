import 'dart:math';

import 'package:flutter/material.dart';

// ── Category enum ─────────────────────────────────────────────────────────────

enum Category {
  food('Food', Icons.restaurant_rounded, Color(0xFFE53935)),
  transport('Transport', Icons.directions_car_rounded, Color(0xFF1E88E5)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFF8E24AA)),
  health('Health', Icons.favorite_rounded, Color(0xFF43A047)),
  other('Other', Icons.more_horiz_rounded, Color(0xFF546E7A));

  const Category(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

// ── Expense model ─────────────────────────────────────────────────────────────

class Expense {
  final String id;
  final String title;
  final double amount;
  final Category category;

  Expense(this.title, this.amount, this.category)
      : id = Random().nextInt(999999).toString();
}

// ── App ───────────────────────────────────────────────────────────────────────

class SpendlyApp extends StatefulWidget {
  const SpendlyApp({super.key});

  @override
  State<SpendlyApp> createState() => _SpendlyAppState();
}

class _SpendlyAppState extends State<SpendlyApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      themeMode: _mode,
      home: HomeScreen(
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: () => setState(
              () => _mode = _mode == ThemeMode.light
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      ),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double kBudget = 1000;

  final List<Expense> _expenses = [
    Expense('Grocery Run', 54.30, Category.food),
    Expense('Bus Pass', 30.00, Category.transport),
    Expense('Netflix', 15.99, Category.other),
    Expense('New Sneakers', 120.00, Category.shopping),
    Expense('Pharmacy', 22.50, Category.health),
  ];

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  void _delete(String id) =>
      setState(() => _expenses.removeWhere((e) => e.id == id));

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          AddExpenseSheet(onAdd: (e) => setState(() => _expenses.insert(0, e))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spendly'),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Budget card ─────────────────────────────────────────
          _BudgetCard(spent: _total, budget: kBudget),
          const SizedBox(height: 16),

          // ── Breakdown card ──────────────────────────────────────
          if (_expenses.isNotEmpty) ...[
            _BreakdownCard(expenses: _expenses),
            const SizedBox(height: 16),
          ],

          // ── Transactions ────────────────────────────────────────
          Text(
            'Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_expenses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No expenses yet. Add one below!'),
              ),
            )
          else
            for (final e in _expenses)
              Dismissible(
                key: Key(e.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _delete(e.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: cs.errorContainer,
                  child: Icon(Icons.delete, color: cs.onErrorContainer),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: e.category.color.withValues(alpha: 0.15),
                      child: Icon(
                        e.category.icon,
                        color: e.category.color,
                        size: 20,
                      ),
                    ),
                    title: Text(e.title),
                    subtitle: Text(e.category.label),
                    trailing: Text(
                      '-\$${e.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: cs.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

// ── Budget Card ───────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final double spent;
  final double budget;

  const _BudgetCard({required this.spent, required this.budget});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (spent / budget).clamp(0.0, 1.0);
    final over = spent > budget;

    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: \$${budget.toStringAsFixed(0)}',
                  style: TextStyle(color: cs.onPrimaryContainer),
                ),
                Text(
                  'Spent: \$${spent.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: over ? cs.error : cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                progress < 0.75 ? cs.primary : cs.error,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              over
                  ? 'Over budget by \$${(spent - budget).toStringAsFixed(2)}'
                  : '\$${(budget - spent).toStringAsFixed(2)} remaining',
              style: TextStyle(
                fontSize: 12,
                color: over ? cs.error : cs.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Breakdown Card ────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final List<Expense> expenses;

  const _BreakdownCard({required this.expenses});

  Map<Category, double> get _totals {
    final map = <Category, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totals = _totals;
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    return Card(
      color: cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final entry in totals.entries) ...[
              Row(
                children: [
                  Icon(entry.key.icon, color: entry.key.color, size: 16),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: Text(
                      entry.key.label,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / grandTotal,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(4),
                      valueColor: AlwaysStoppedAnimation(entry.key.color),
                      backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Add Expense Sheet ─────────────────────────────────────────────────────────

class AddExpenseSheet extends StatefulWidget {
  final Function(Expense) onAdd;

  const AddExpenseSheet({super.key, required this.onAdd});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  Category _selected = Category.food;

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text);
    if (title.isEmpty || amount == null || amount <= 0) return;
    widget.onAdd(Expense(title, amount, _selected));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Expense',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            children: Category.values.map((cat) {
              final selected = cat == _selected;
              return ChoiceChip(
                label: Text(cat.label),
                selected: selected,
                avatar: Icon(
                  cat.icon,
                  size: 16,
                  color: selected ? Colors.white : cat.color,
                ),
                onSelected: (_) => setState(() => _selected = cat),
                selectedColor: cat.color,
                labelStyle: TextStyle(color: selected ? Colors.white : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _submit, child: const Text('Add')),
          ),
        ],
      ),
    );
  }
}
