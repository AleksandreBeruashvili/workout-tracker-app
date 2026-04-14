import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: MyExpensesScreen(),
    );
  }
}

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({super.key});

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  final double _budget = 5000.0;
  final List<int> _expenses = [];

  double get _totalSpent =>
      _expenses.fold(0.0, (sum, item) => sum + item);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses App'),
        actions: [IconButton(icon: Icon(Icons.dark_mode), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
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
                        'Budget: \$${_budget.toStringAsFixed(0)}',
                        style: TextStyle(color: cs.onPrimaryContainer),
                      ),
                      Text(
                        'Spent: \$${_totalSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: cs.onPrimaryContainer.withValues(
                      alpha: 0.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${(_budget - _totalSpent).toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.eighteen_mp_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 72,
                        child: Text(
                          'Label',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.2,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${100.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.eighteen_mp_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: Text('Title'),
              subtitle: Text('Subtitle'),
              trailing: Text(
                '-\$${100.toStringAsFixed(2)}',
                style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class ExpenseInfoCard extends StatelessWidget {
  const ExpenseInfoCard({
    super.key,
    required this.budget,
    required this.totalSpent,
  });

  final double budget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          spacing: 10.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget: \$$budget'),
                Text('Spent: \$$totalSpent'),
              ],
            ),
            LinearProgressIndicator(
              value: (totalSpent / budget).clamp(0, 1),
              borderRadius: BorderRadius.circular(50.0),
              minHeight: 7.0,
            ),
            Text('\$${budget - totalSpent} remaining'),
          ],
        ),
      ),
    );
  }
}