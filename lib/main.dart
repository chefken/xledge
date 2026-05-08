import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/root_screen.dart';
import 'package:xledge/utils/void_colors.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/void_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(DebtAdapter());
  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<Debt>(HiveBoxes.debts);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoidProvider()),
      ],
      child: const XledgeApp(),
    ),
  );
}

class XledgeApp extends StatelessWidget {
  const XledgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xledge',
      debugShowCheckedModeBanner: false,
      theme: VoidTheme.light,
      home: const RootScreen(),
    );
  }
}