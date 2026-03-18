import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mini_habit_tracker/auth/auth_gate.dart';
import 'package:mini_habit_tracker/database/birthday_database.dart';
import 'package:mini_habit_tracker/database/expense_database.dart';
import 'package:mini_habit_tracker/database/habit_database.dart';
import 'package:mini_habit_tracker/pages/add_habit_page.dart';
import 'package:mini_habit_tracker/services/firestore_habit_service.dart';
import 'package:mini_habit_tracker/services/mood_habit_service.dart';
import 'package:mini_habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mini_habit_tracker/services/user_service.dart';
import 'package:mini_habit_tracker/services/period_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  tz.initializeTimeZones();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HabitDatabase(),
        ),
        Provider(
          create: (context) => FirestoreHabitService(),
        ),
        ChangeNotifierProvider(create: (context) => UserService()..load()),
ChangeNotifierProvider(create: (context) => PeriodService()),
        ChangeNotifierProvider(create: (context) => MoodHabitService()),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ExpenseDatabase(),
        ),
        // ✅ NEW: Birthday database
        ChangeNotifierProvider(
          create: (context) => BirthdayDatabase(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Habit Tracker',
      theme: themeProvider.themeData.copyWith(
        textTheme: GoogleFonts.ralewayTextTheme(
          themeProvider.themeData.textTheme,
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/addHabit': (context) => const AddHabitPage(),
      },
    );
  }
}
