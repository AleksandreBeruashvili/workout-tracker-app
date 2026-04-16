import 'dart:math';

import 'package:flutter/material.dart';

enum Category {
  food(label: 'Food', icon: Icons.fastfood, color: Colors.orange),
  transport(label: 'Transport', icon: Icons.directions_car, color: Colors.blue),
  entertainment(
    label: 'Entertainment',
    icon: Icons.movie,
    color: Colors.purple,
  ),
  utilities(label: 'Utilities', icon: Icons.light_mode, color: Colors.green),
  others(label: 'Others', icon: Icons.category, color: Colors.grey);

  final String label;
  final IconData icon;
  final Color color;

  const Category({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class Expense {
  final int id;
  final String title;
  final double amount;
  final Category category;

  Expense(this.id, this.title, this.amount, this.category);
}

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
  final List<Expense> _transactions = [
    Expense(1, 'Groceries', 150.0, Category.food),
    Expense(2, 'Movie Tickets', 40.0, Category.entertainment),
    Expense(3, 'Electricity Bill', 120.0, Category.utilities),
    Expense(4, 'Taxi Ride', 30.0, Category.transport),
  ];

  double get _totalSpent =>
      _transactions.fold(0.0, (result, expense) => result + expense.amount);

  Map<Category, double> get _categoryExpense =>
      _transactions.fold({}, (map, expense) {
        map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
        return map;
      });

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
                    value: _totalSpent / _budget,
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
                  if (_transactions.isEmpty) Text('No Transactions'),
                  ..._categoryExpense.keys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Icon(key.icon, color: key.color, size: 16),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 72,
                            child: Text(
                              key.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (_categoryExpense[key] ?? 0) / _totalSpent,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: cs.onSurface.withValues(
                                alpha: 0.08,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\$${(_categoryExpense[key] ?? 0).toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          if (_transactions.isEmpty) Text('No Transaction Fount'),
          ..._transactions.map(
            (transaction) => Dismissible(
              key: ValueKey(transaction.id),
              onDismissed: (_) {
                setState(() {
                  _transactions.removeWhere(
                    (item) => item.id == transaction.id,
                  );
                });
              },
              background: Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.only(right: 24.0),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.category.color.withValues(
                      alpha: 0.3,
                    ),
                    child: Icon(
                      transaction.category.icon,
                      color: transaction.category.color,
                      size: 20,
                    ),
                  ),
                  title: Text(transaction.title),
                  subtitle: Text(transaction.category.label),
                  trailing: Text(
                    '-\$${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          setState(() {
            _transactions.add(result);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  Category selectedCategory = Category.food;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Add Expense')),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          Wrap(
            spacing: 10,
            direction: Axis.horizontal,
            children: Category.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(item.label),
                    selected: item.label == selectedCategory.label,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = item;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              final amountText = _amountController.text.trim();
              if (title.isEmpty || amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              final transaction = Expense(
                Random().nextInt(9999),
                title,
                amount,
                selectedCategory,
              );

              Navigator.of(context).pop(transaction);
            },
            child: Text('Add Expense'),
          ),
        ],
      ),
    );
  }
}
