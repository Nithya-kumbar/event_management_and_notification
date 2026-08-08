import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/admin_service.dart';
import '../utils/app_colors.dart';
import '../widgets/college_logo_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final adminService = context.read<AdminService>();

    final result = await adminService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result["success"] == true) {
      Navigator.pushReplacementNamed(
        context,
        "/admin-dashboard",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Admin Login"),
        backgroundColor: AppColors.primary,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 30,
          ),

          child: Column(
            children: [

              const CollegeLogoWidget(
                size: 90,
                showName: true,
                showTagline: true,
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Administrator",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Login using your administrator account.",
                        style: GoogleFonts.poppins(
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 30),

                      CustomTextField(
                        label: "Admin Email",

                        hint: "enter your admin email",

                        controller: _emailController,

                        keyboardType:
                            TextInputType.emailAddress,

                        prefixIcon: Icons.admin_panel_settings,

                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return "Email required";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      TextFormField(
                        controller: _passwordController,

                        obscureText: _obscurePassword,

                        decoration: InputDecoration(
                          labelText: "Password",

                          prefixIcon:
                              const Icon(Icons.lock),

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),

                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),

                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "Password required";
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      Consumer<AdminService>(
                        builder:
                            (_, adminService, __) {

                          return CustomButton(
                            text: "Login",

                            icon:
                                Icons.login_rounded,

                            onPressed: _login,

                            isLoading:
                                adminService.isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon:
                            const Icon(Icons.arrow_back),

                        label:
                            const Text("Back to Student Login"),

                        style: OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                                  double.infinity,
                                  50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}