import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Import your project files
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/utils/void_theme.dart';
import 'package:xledge/screens/expenses_screen.dart';
import 'package:xledge/utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(DebtAdapter());

  // Open Boxes
  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<Debt>(HiveBoxes.debts);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoidProvider()),
      ],
      child: const XLedgeApp(),
    ),
  );
}

class XLedgeApp extends StatelessWidget {
  const XLedgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xledge',
      debugShowCheckedModeBanner: false,
      theme: VoidTheme.dark, // Ensure this exists in your void_theme.dart
      home: const ExpensesScreen(),
    );
  }
}