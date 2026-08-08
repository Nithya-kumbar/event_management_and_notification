import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

Color _deptColorFor(String dept) {
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

// Shared header used by both card types.
// Shows the real uploaded image (tappable to view full-screen),
// a tappable PDF placeholder (opens the brochure externally),
// or the gradient fallback when nothing was uploaded.
Widget buildCardHeader(
  BuildContext context,
  EventModel event,
  Color deptColor,
  double height,
) {
  final hasImage = event.imageUrl != null &&
      event.imageUrl!.isNotEmpty &&
      event.fileType == "IMAGE";
  final hasPdf = event.imageUrl != null &&
      event.imageUrl!.isNotEmpty &&
      event.fileType == "PDF";

  if (hasImage) {
    final fullUrl = "${AppConstants.fileBaseUrl}${event.imageUrl}";
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BrochureImageViewer(url: fullUrl),
        ),
      ),
      child: Image.network(
        fullUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            color: deptColor.withAlpha(40),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [deptColor.withAlpha(220), deptColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white70, size: 36),
          ),
        ),
      ),
    );
  }

  if (hasPdf) {
    final fullUrl = "${AppConstants.fileBaseUrl}${event.imageUrl}";
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(fullUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [deptColor.withAlpha(220), deptColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.picture_as_pdf, color: Colors.white, size: 45),
        ),
      ),
    );
  }

  return Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [deptColor.withAlpha(220), deptColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Icon(Icons.event, color: Colors.white.withAlpha(120), size: 45),
    ),
  );
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deptColor = _deptColorFor(event.department);

    final formattedDate =
        DateFormat('EEE, MMM d, yyyy').format(event.eventDate);

    final isPdf = event.imageUrl != null &&
        event.imageUrl!.isNotEmpty &&
        event.fileType == "PDF";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  buildCardHeader(context, event, deptColor, 140),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Text(
                      event.eventName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: deptColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.department,
                          style: TextStyle(
                            color: deptColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isPdf) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.picture_as_pdf,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 2),
                        const Text(
                          "Brochure",
                          style: TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: formattedDate,
                  ),

                  const SizedBox(height: 6),

                  InfoRow(
                    icon: Icons.access_time_outlined,
                    text: event.eventTime,
                  ),

                  const SizedBox(height: 6),

                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: event.location,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                SizedBox(
  width: double.infinity,
  height: 42,
  child: ElevatedButton(
    onPressed: event.isRegistrationClosed ? null : onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor:
          event.isRegistrationClosed ? Colors.grey.shade400 : deptColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: Text(
      event.isRegistrationClosed ? 'Registration Closed' : 'View & Register',
      style: const TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCardHorizontal extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCardHorizontal({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deptColor = _deptColorFor(event.department);

    final formattedDate = DateFormat('MMM d').format(event.eventDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  buildCardHeader(context, event, deptColor, 90),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: deptColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMedium),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }
}

class BrochureImageViewer extends StatelessWidget {
  final String url;
  const BrochureImageViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(url),
        ),
      ),
    );
  }
}