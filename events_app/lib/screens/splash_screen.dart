// ============================================================
// splash_screen.dart - App Splash / Loading Screen
// Place this file at: lib/screens/splash_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/college_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for logo fade + slide in
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Set up fade + slide animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation then navigate after delay
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // TODO: Check shared_preferences for saved session here
    // If token exists → go to /home, else → go to /login
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Rich gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2554), // deep navy
              Color(0xFF1A3C6E), // primary blue
              Color(0xFF2158A4), // lighter blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles in background
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: 30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
            ),
            // Main content centered
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // College logo (white version on dark bg)
                      CollegeLogoWidget(
                        size: 100,
                        showName: true,
                        showTagline: true,
                        textColor: Colors.white,
                        logoColor: AppColors.primary,
                      ),
                      const SizedBox(height: 48),
                      // App name
                      Text(
                        'Campus Events',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your college life, organized.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Loading indicator
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom credit text
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                '© ${AppConstants.collegeName}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
