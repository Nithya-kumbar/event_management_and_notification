// ============================================================
// register_screen.dart - User Registration Page
// Place this file at: lib/screens/register_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/college_logo_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _usnController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Selected department from dropdown
  String? _selectedDepartment;

  // Exclude 'All' from registration department list
  List<String> get _deptOptions =>
      AppConstants.departments.where((d) => d != 'All').toList();

  @override
  void dispose() {
    _nameController.dispose();
    _usnController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final result = await authService.register(
  name: _nameController.text.trim(),
  usn: _usnController.text.trim(),
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
  confirmPassword: _confirmPasswordController.text.trim(),
  department: _selectedDepartment ?? '',
);
  

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Go back to login
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Compact logo at top
              const CollegeLogoWidget(size: 60, showName: false),
              const SizedBox(height: 20),

              // Registration card
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
                      Text(
                        'Create Account',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join the campus events community',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full name field
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'e.g. Alex Johnson',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
CustomTextField(
  label: 'USN',
  hint: 'e.g. 1NH25MC082',
  controller: _usnController,
  prefixIcon: Icons.badge_outlined,
  validator: (v) {
    if (v == null || v.trim().isEmpty) {
      return 'USN is required';
    }

    return null;
  },
),

const SizedBox(height: 14),
                      // Email field
                      CustomTextField(
                       label: 'Gmail Address',
hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                       validator: (v) {
  if (v == null || v.isEmpty) {
    return 'Email is required';
  }

  final email = v.trim().toLowerCase();

  if (!RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
    return 'Enter a valid Gmail address';
  }

  return null;
},
                      ),
                      const SizedBox(height: 14),

                      // Department dropdown
                      CustomDropdownField(
                        label: 'Department',
                        hint: 'Select your department',
                        value: _selectedDepartment,
                        items: _deptOptions,
                        onChanged: (v) =>
                            setState(() => _selectedDepartment = v),
                      ),
                      const SizedBox(height: 14),

                      // Password field
                      CustomTextField(
                        label: 'Password',
                        hint: 'Minimum 6 characters',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password is required';
                          if (v.length < 6)
                            return 'Minimum 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm password field
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Please confirm password';
                          if (v != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Register button
                      Consumer<AuthService>(
                        builder: (context, auth, _) {
                          return CustomButton(
                            text: 'Create Account',
                            onPressed: _handleRegister,
                            isLoading: auth.isLoading,
                            color: AppColors.accent,
                            icon: Icons.person_add_outlined,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Navigate to login
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                color: AppColors.textMedium,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
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
