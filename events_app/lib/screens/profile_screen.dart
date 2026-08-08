// lib/screens/profile_screen.dart
// Save at: lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/event_card.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../services/registration_service.dart';
import '../models/event_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RegistrationService _registrationService = RegistrationService();

  late Future<List<EventModel>> _registeredEvents;
  late Future<int> _registrationCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
  }

  void _refresh() {
    final userId = context.read<AuthService>().userId!;
    _registeredEvents = _registrationService.getUserRegistrations(userId);
    _registrationCount = _registrationService.getRegistrationCount(userId);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.pushNamedAndRemoveUntil(
            context, '/home', (route) => false);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false),
          ),
          actions: [
            // Settings icon → Edit Profile
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Edit Profile',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                );
                // Refresh profile data after returning from edit
                if (mounted) setState(() => _refresh());
              },
            ),
          ],
        ),
        body: Consumer2<AuthService, EventService>(
          builder: (context, auth, eventService, _) {
            final user = auth.currentUser;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(
                      user?.name ?? 'Student',
                      user?.department ?? ''),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                            user?.email ?? '',
                            user?.department ?? ''),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Registered Events',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Events you have registered for',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMedium)),
                        const SizedBox(height: 12),

                        FutureBuilder<List<EventModel>>(
                          future: _registeredEvents,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return _buildNoRegisteredEvents();
                            }
                            return Column(
                              children: snapshot.data!
                                  .map((event) => EventCard(
                                        event: event,
                                        onTap: () =>
                                            Navigator.pushNamed(
                                          context,
                                          '/event-details',
                                          arguments: event.toArgs(),
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                        // Edit profile button (alternative entry point)
                        CustomButton(
                          text: 'Edit Profile',
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileScreen()),
                            );
                            if (mounted) setState(() => _refresh());
                          },
                          color: AppColors.primary,
                          icon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 12),

                        CustomButton(
                          text: 'Sign Out',
                          onPressed: () async {
                            await auth.logout();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          color: AppColors.error,
                          icon: Icons.logout_rounded,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String department) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(name,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              department.isNotEmpty ? department : 'Student',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String email, String department) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account Information',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const Divider(height: 20),
          _ProfileInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email.isNotEmpty ? email : 'Not available'),
          const SizedBox(height: 12),
          _ProfileInfoRow(
              icon: Icons.school_outlined,
              label: 'Department',
              value: department.isNotEmpty ? department : 'Not set'),
          const SizedBox(height: 12),
          _ProfileInfoRow(
              icon: Icons.badge_outlined, label: 'Role', value: 'Student'),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return FutureBuilder<int>(
      future: _registrationCount,
      builder: (context, snapshot) {
        final registered = snapshot.data ?? 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                    registered.toString(), 'Registered', AppColors.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoRegisteredEvents() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 40, color: AppColors.textLight),
          const SizedBox(height: 8),
          const Text('No registered events yet',
              style:
                  TextStyle(color: AppColors.textMedium, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight)),
            Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}
