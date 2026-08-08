// lib/screens/notifications_screen.dart
// Save at: lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/notification_api_service.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _apiService = NotificationApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthService>().userId!;
    final data = await _apiService.getNotifications(userId);
    // Mark all as read when inbox is opened
    await _apiService.markAllRead(userId);
    if (mounted) {
      setState(() {
        _notifications = data;
        _loading = false;
      });
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'REMINDER_1_DAY':    return Icons.calendar_today;
      case 'REMINDER_1_HOUR':   return Icons.access_time;
      case 'REMINDER_15_MIN':   return Icons.timer;
      case 'EVENT_START':       return Icons.play_circle_outline;
      case 'DEADLINE_UNREGISTERED': return Icons.warning_amber_rounded;
      default:                  return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'REMINDER_1_DAY':    return AppColors.primary;
      case 'REMINDER_1_HOUR':   return Colors.orange;
      case 'REMINDER_15_MIN':   return Colors.deepOrange;
      case 'EVENT_START':       return Colors.green;
      case 'DEADLINE_UNREGISTERED': return Colors.red;
      default:                  return AppColors.primary;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'REMINDER_1_DAY':    return '1 Day Before';
      case 'REMINDER_1_HOUR':   return '1 Hour Before';
      case 'REMINDER_15_MIN':   return '15 Min Before';
      case 'EVENT_START':       return 'Starting Now';
      case 'DEADLINE_UNREGISTERED': return 'Not Registered';
      default:                  return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) =>
                        _buildCard(_notifications[index]),
                  ),
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> n) {
    final type = n['notificationType'] ?? n['type'] ?? '';
    final color = _colorForType(type);
    final isRead = n['isRead'] == true;
    final createdAt = n['createdAt'] != null
        ? DateTime.tryParse(n['createdAt'].toString())
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRead ? AppColors.border : color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_iconForType(type), color: color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                n['title'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              n['message'] ?? '',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _labelForType(type),
                    style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (createdAt != null)
                  Text(
                    DateFormat('MMM d, h:mm a').format(createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textLight),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium),
          ),
          const SizedBox(height: 8),
          const Text(
            'Event reminders will appear here',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
