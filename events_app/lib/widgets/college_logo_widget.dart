// ============================================================
// college_logo_widget.dart - Reusable College Branding Widget
// Place this file at: lib/widgets/college_logo_widget.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

// College logo + name used on splash, login, and app bar
class CollegeLogoWidget extends StatelessWidget {
  final double size;
  final bool showName;
  final bool showTagline;
  final Color? logoColor;
  final Color? textColor;

  const CollegeLogoWidget({
    super.key,
    this.size = 80,
    this.showName = true,
    this.showTagline = false,
    this.logoColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // College logo placeholder - replace with Image.asset() when logo is available
       Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: ClipOval(
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/e/e3/New_Horizon_College_of_Engineering_logo.png',
        fit: BoxFit.cover,
      ),
    ),
  ),
),
        if (showName) ...[
          const SizedBox(height: 14),
          Text(
            AppConstants.collegeName,
            textAlign: TextAlign.center,
            style: GoogleFonts.merriweather(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor ?? AppColors.textDark,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            AppConstants.collegeTagline,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: (textColor ?? AppColors.textMedium).withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// Compact horizontal logo for app bar
class CollegeLogoAppBar extends StatelessWidget {
  const CollegeLogoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Text(
              AppConstants.collegeShortName,
              style: GoogleFonts.merriweather(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            AppConstants.collegeName,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
