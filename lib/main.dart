import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xledge/models/debt_model.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/providers/theme_provider.dart';
import 'package:xledge/providers/void_provider.dart';
import 'package:xledge/screens/root_screen.dart';
import 'package:xledge/services/category_service.dart';
import 'package:xledge/services/user_prefs_service.dart';
import 'package:xledge/utils/void_constants.dart';
import 'package:xledge/utils/void_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(DebtAdapter());
  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<Debt>(HiveBoxes.debts);
  await UserPrefsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VoidProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
      ],
      child: const XledgeApp(),
    ),
  );
}

class XledgeApp extends StatelessWidget {
  const XledgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'xledge',
          debugShowCheckedModeBanner: false,
          theme:      VoidTheme.light,
          darkTheme:  VoidTheme.dark,
          themeMode:  themeProvider.themeMode,
          home: const RootScreen(),
        );
      },
    );
  }
}