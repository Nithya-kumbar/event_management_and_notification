// ============================================================
// login_screen.dart - User Login Page
// Place this file at: lib/screens/login_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../widgets/college_logo_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login button press
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result['success']) {
      // Navigate to home dashboard on success
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // College logo and name at top
              const CollegeLogoWidget(
                size: 90,
                showName: true,
                showTagline: true,
              ),
              const SizedBox(height: 36),

              // Login card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome heading
                      Text(
                        'Welcome Back! ',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to explore college events',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Email field
                      CustomTextField(
                        label: 'Gmail Address',
                        hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }

                          final email = value.trim().toLowerCase();

                          if (!RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
                            return 'Enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password flow
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Login button with loading state from provider
                      Consumer<AuthService>(
                        builder: (context, auth, _) {
                          return CustomButton(
                            text: 'Sign In',
                            onPressed: _handleLogin,
                            isLoading: auth.isLoading,
                            icon: Icons.login_rounded,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 12),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Register navigation
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                color: AppColors.textMedium,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Register here',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
