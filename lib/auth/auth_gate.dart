// lib/auth/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/pages/home_page.dart';
import 'package:mini_habit_tracker/pages/login_or_register_page.dart';
import 'package:mini_habit_tracker/pages/onboarding_page.dart';
import 'package:mini_habit_tracker/services/user_service.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. USER LOGGED IN — check if they've completed onboarding
          if (snapshot.hasData) {
            return Consumer<UserService>(
              builder: (ctx, userSvc, _) {
                // First time? Show onboarding
                if (!userSvc.onboarded) {
                  return OnboardingPage(onComplete: () {});
                }
                // Already onboarded → go to app
                return const HomePage();
              },
            );
          }

          // 3. NO USER — show login/register
          return const LoginOrRegisterPage();
        },
      ),
    );
  }
}