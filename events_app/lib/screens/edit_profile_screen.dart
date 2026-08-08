// lib/screens/edit_profile_screen.dart
// Save at: lib/screens/edit_profile_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedDepartment;
  bool _loading = false;
  bool _saving = false;

  List<String> get _deptOptions =>
      AppConstants.departments.where((d) => d != 'All').toList();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final userId = context.read<AuthService>().userId!;
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/profile?userId=$userId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _nameController.text  = data['name']       ?? '';
        _emailController.text = data['email']      ?? '';
        _phoneController.text = data['phone']      ?? '';
        final dept = data['department']?.toString() ?? '';
        if (_deptOptions.contains(dept)) {
          setState(() => _selectedDepartment = dept);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final userId = context.read<AuthService>().userId!;
    try {
      final response = await http.put(
        Uri.parse(
            '${AppConstants.baseUrl}/profile?requestingUserId=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'department': _selectedDepartment ?? '',
          'phone': _phoneController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (data['success'] == true) {
        // Update local auth state so home screen greeting updates
        final auth = context.read<AuthService>();
        auth.updateLocalProfile(
          name: data['name'],
          email: data['email'],
          department: data['department'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Update failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server connection failed')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar header
                    Center(
                      child: Stack(
                        children: [
                          Consumer<AuthService>(
                            builder: (context, auth, _) {
                              final name =
                                  auth.currentUser?.name ?? 'S';
                              return CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : 'S',
                                  style: GoogleFonts.poppins(
                                      fontSize: 36,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text('Personal Information',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Full Name',
                      hint: 'Your full name',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Gmail Address',
                      hint: 'example@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      label: 'Phone Number',
                      hint: 'e.g. 9876543210',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 14),

                    CustomDropdownField(
                      label: 'Department',
                      hint: 'Select your department',
                      value: _selectedDepartment,
                      items: _deptOptions,
                      onChanged: (v) =>
                          setState(() => _selectedDepartment = v),
                    ),

                    const SizedBox(height: 28),

                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _save,
                      isLoading: _saving,
                      icon: Icons.save_outlined,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
