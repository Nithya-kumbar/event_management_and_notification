import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';
import '../utils/app_colors.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

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
    final deptColor = _deptColor(event.department);

    final formattedDate =
        DateFormat('EEE, MMM d, yyyy').format(event.eventDate);

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
            // Top Gradient Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      deptColor.withAlpha(220),
                      deptColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department Tag
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

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: formattedDate,
                  ),

                  const SizedBox(height: 6),

                  _InfoRow(
                    icon: Icons.access_time_outlined,
                    text: event.eventTime,
                  ),

                  const SizedBox(height: 6),

                  _InfoRow(
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
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deptColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View & Register',
                        style: TextStyle(
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
    final deptColor = _deptColor(event.department);

    final formattedDate =
        DateFormat('MMM d').format(event.eventDate);

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
              child: Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      deptColor.withAlpha(220),
                      deptColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.event,
                        color: Colors.white.withAlpha(120),
                        size: 45,
                      ),
                    ),

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
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: deptColor,
                      ),

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textMedium,
        ),

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