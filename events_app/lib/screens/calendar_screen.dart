// ============================================================
// calendar_screen.dart - Events Calendar Page
// Place this file at: lib/screens/calendar_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import '../utils/app_colors.dart';
import '../widgets/event_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // Navigate to previous month
  void _prevMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  // Navigate to next month
  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  // Get all days to display for current month view (including leading/trailing days)
  List<DateTime?> _getDaysInMonth() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun, 6=Sat

    final days = <DateTime?>[];
    // Add leading nulls for days before month starts
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    // Add all days in month
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Calendar'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false),
        ),
      ),
      body: Consumer<EventService>(
        builder: (context, eventService, _) {
          final eventsOnDate = eventService.getEventsByDate(_selectedDate);
          final allEvents = eventService.allEvents;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Calendar widget
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Month navigation header
                      _buildMonthHeader(),
                      const SizedBox(height: 12),
                      // Day-of-week labels
                      _buildWeekdayLabels(),
                      const SizedBox(height: 6),
                      // Calendar grid
                      _buildCalendarGrid(allEvents),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Events for selected date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Events on ${DateFormat('EEEE, MMMM d').format(_selectedDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (eventsOnDate.isEmpty)
                        _buildNoEventsCard()
                      else
                        ...eventsOnDate.map((event) => EventCard(
                              event: event,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/event-details',
                                arguments: event.toArgs(),
                              ),
                            )),

                      const SizedBox(height: 32),
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

  // Month title + prev/next navigation arrows
  Widget _buildMonthHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
          onPressed: _prevMonth,
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  // Sun-Sat labels
  Widget _buildWeekdayLabels() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
              ))
          .toList(),
    );
  }

  // Calendar date grid
  // Calendar date grid
Widget _buildCalendarGrid(List<EventModel> allEvents) {
  final days = _getDaysInMonth();

  return SizedBox(
    height: 300,
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];

        if (day == null) {
          return const SizedBox();
        }

        final isToday =
            day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;

        final isSelected =
            day.year == _selectedDate.year &&
            day.month == _selectedDate.month &&
            day.day == _selectedDate.day;

        // Check if event exists on this day
        final hasEvent = allEvents.any(
          (e) =>
              e.eventDate.year == day.year &&
              e.eventDate.month == day.month &&
              e.eventDate.day == day.day,
        );

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.primary
                            : AppColors.textDark,
                  ),
                ),

                // Small event indicator dot
                if (hasEvent)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : AppColors.accent,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// Empty state when no events on selected date
Widget _buildNoEventsCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(
          Icons.event_available,
          size: 48,
          color: AppColors.textLight,
        ),

        const SizedBox(height: 12),

        const Text(
          'No events scheduled for this date',
          style: TextStyle(
            color: AppColors.textMedium,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Select another date to see events',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
}