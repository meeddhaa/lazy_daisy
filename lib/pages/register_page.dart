import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnims = List.generate(6, (i) {
      final start = 0.08 * i;
      return Tween<Offset>(
              begin: const Offset(0, 0.18), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _ctrl,
              curve:
                  Interval(start, start + 0.6, curve: Curves.easeOut)));
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUserUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      _showError('Passwords don\'t match. Try again.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (mounted) setState(() => _loading = false);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _loading = false);
      _showError(_friendlyError(e.code));
    }
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in!';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(message,
                  style:
                      const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
      backgroundColor: const Color(0xFFE57373),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDF8),
      body: Stack(
        children: [
          // ── background blobs ─────────────────
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFACD).withOpacity(0.6)),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9370DB).withOpacity(0.1)),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),

                      // Icon + title
                      SlideTransition(
                        position: _slideAnims[0],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFF176),
                                    Color(0xFFFFD54F)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0xFFFFD54F)
                                          .withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8))
                                ],
                              ),
                              child: const Center(
                                  child: Text('✨',
                                      style: TextStyle(fontSize: 30))),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'Start Your\nJourney 🌱',
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D1B69),
                                  height: 1.15),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Build habits that stick. One day at a time.',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(0.4),
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email
                      SlideTransition(
                        position: _slideAnims[1],
                        child: _buildLabel('Email address'),
                      ),
                      const SizedBox(height: 8),
                      SlideTransition(
                        position: _slideAnims[1],
                        child: _buildTextField(
                          controller: emailController,
                          hint: 'you@example.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Password
                      SlideTransition(
                        position: _slideAnims[2],
                        child: _buildLabel('Password'),
                      ),
                      const SizedBox(height: 8),
                      SlideTransition(
                        position: _slideAnims[2],
                        child: _buildPasswordField(
                            controller: passwordController,
                            hint: '••••••••',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword)),
                      ),

                      const SizedBox(height: 18),

                      // Confirm password
                      SlideTransition(
                        position: _slideAnims[3],
                        child: _buildLabel('Confirm Password'),
                      ),
                      const SizedBox(height: 8),
                      SlideTransition(
                        position: _slideAnims[3],
                        child: _buildPasswordField(
                            controller: confirmPasswordController,
                            hint: '••••••••',
                            obscure: _obscureConfirm,
                            onToggle: () => setState(
                                () => _obscureConfirm = !_obscureConfirm)),
                      ),

                      const SizedBox(height: 32),

                      // Sign up button
                      SlideTransition(
                        position: _slideAnims[4],
                        child: _buildSignUpButton(),
                      ),

                      const SizedBox(height: 28),

                      // Divider
                      SlideTransition(
                        position: _slideAnims[4],
                        child: Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.black.withOpacity(0.1))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.35),
                                      fontSize: 13)),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.black.withOpacity(0.1))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login link
                      SlideTransition(
                        position: _slideAnims[5],
                        child: Center(
                          child: GestureDetector(
                            onTap: widget.onTap,
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 14),
                                children: const [
                                  TextSpan(
                                    text: 'Log In →',
                                    style: TextStyle(
                                        color: Color(0xFF9370DB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9370DB)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          prefixIcon:
              Icon(icon, color: Colors.black.withOpacity(0.3), size: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.3), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          prefixIcon: Icon(Icons.lock_outline_rounded,
              color: Colors.black.withOpacity(0.3), size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.black.withOpacity(0.35),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _loading ? null : signUserUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _loading
                ? [const Color(0xFFFFD54F), const Color(0xFFFFD54F)]
                : [const Color(0xFFFFD54F), const Color(0xFFFFB300)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFFD54F).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : const Text('Create Account',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5)),
        ),
      ),
    );
  }
}