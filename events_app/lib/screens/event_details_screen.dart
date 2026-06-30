// ============================================================
// event_details_screen.dart - Full Event Info Page
// Place this file at: lib/screens/event_details_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

import '../services/registration_service.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class EventDetailsScreen extends StatelessWidget {
  // Receives event data as navigation arguments
  final Map<String, dynamic> eventData;

  const EventDetailsScreen({super.key, required this.eventData});

  Color _deptColor(String dept) {
    switch (dept) {
      case 'Computer Science':
        return AppColors.deptCS;
      case 'Electronics & ECE':
        return AppColors.deptECE;
      case 'Mechanical':
        return AppColors.deptMech;
      case 'Civil Engineering':
        return AppColors.deptCivil;
      case 'MBA':
        return AppColors.deptMBA;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reconstruct event from arguments map
    final event = EventModel.fromJson(eventData);
    final deptColor = _deptColor(event.department);
    final formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(event.eventDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Large image header with back button
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: deptColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient image placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          deptColor.withOpacity(0.9),
                          deptColor,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                  // Decorative pattern
                  CustomPaint(painter: _GridPatternPainter(deptColor)),
                  // Event icon
                  Center(
                    child: Icon(
                      Icons.event_note_rounded,
                      size: 80,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  // Category badge
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: deptColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.department,
                      style: TextStyle(
                        color: deptColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Event name
                  Text(
                    event.eventName,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info cards row
                  _buildInfoCard(event, deptColor, formattedDate),
                  const SizedBox(height: 20),

                  // Description section
                  Text(
                    'About This Event',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textMedium,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Organizer info
                  _buildOrganizerCard(event, deptColor),
                  const SizedBox(height: 28),

                  // Registration button
                  CustomButton(
                    text: 'Register for This Event',
onPressed: () async {
  try {
    final authService =
        Provider.of<AuthService>(context, listen: false);

    final userId = authService.userId!;

    String message = await RegistrationService().registerEvent(
      userId: userId,
      eventId: event.id,
    );

    if (message == "Registration Successful") {
      await NotificationService().scheduleEventReminder(
        eventId: event.id,
        title: event.eventName,
        eventDate: event.eventDate,
        eventTime: event.eventTime,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
},
                    icon: Icons.how_to_reg_rounded,
                    color: deptColor,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event details info card (date, time, venue)
  Widget _buildInfoCard(
      EventModel event, Color deptColor, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: formattedDate,
            color: deptColor,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: event.eventTime,
            color: deptColor,
          ),
          const Divider(height: 20),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: 'Venue',
            value: event.location,
            color: deptColor,
          ),
        ],
      ),
    );
  }

  // Organizer info card
  Widget _buildOrganizerCard(EventModel event, Color deptColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: deptColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deptColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: deptColor,
            child: Text(
              event.organizer.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organized by',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.organizer,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Row widget for date/time/venue details
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textLight),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Grid pattern painter for event detail hero image
class _GridPatternPainter extends CustomPainter {
  final Color baseColor;
  _GridPatternPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
