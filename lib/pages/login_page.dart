import 'package:flutter/material.dart';
import 'package:mini_habit_tracker/pages/login_page.dart';
import 'package:mini_habit_tracker/pages/register_page.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage>
    with SingleTickerProviderStateMixin {
  bool showLoginPage = true;

  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> togglePages() async {
    await _ctrl.reverse();
    setState(() => showLoginPage = !showLoginPage);
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: showLoginPage
            ? LoginPage(onTap: togglePages)
            : RegisterPage(onTap: togglePages),
      ),
    );
  }
}