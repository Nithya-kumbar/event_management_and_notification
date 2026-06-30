// ============================================================
// department_filter_screen.dart - Events by Department
// Place this file at: lib/screens/department_filter_screen.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/event_card.dart';

class DepartmentFilterScreen extends StatefulWidget {
  const DepartmentFilterScreen({super.key});

  @override
  State<DepartmentFilterScreen> createState() => _DepartmentFilterScreenState();
}

class _DepartmentFilterScreenState extends State<DepartmentFilterScreen> {
  // Map department names to display colors
  final Map<String, Color> _deptColors = {
    'All': AppColors.primary,
    'Computer Science': AppColors.deptCS,
    'Electronics & ECE': AppColors.deptECE,
    'Mechanical': AppColors.deptMech,
    'Civil Engineering': AppColors.deptCivil,
    'MBA': AppColors.deptMBA,
    'Cultural': const Color(0xFFEC4899),
    'Physics': const Color(0xFF14B8A6),
    'Mathematics': const Color(0xFF6366F1),
  };

  // Map department names to icons
  final Map<String, IconData> _deptIcons = {
    'All': Icons.apps_rounded,
    'Computer Science': Icons.computer_outlined,
    'Electronics & ECE': Icons.electrical_services_outlined,
    'Mechanical': Icons.settings_outlined,
    'Civil Engineering': Icons.business_outlined,
    'MBA': Icons.business_center_outlined,
    'Cultural': Icons.music_note_outlined,
    'Physics': Icons.science_outlined,
    'Mathematics': Icons.calculate_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse by Department'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
body: Consumer<EventService>(
  builder: (context, eventService, _) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Select Department',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
              ),
              itemCount: AppConstants.departments.length,
              itemBuilder: (context, index) {
                final dept = AppConstants.departments[index];
                final color =
                    _deptColors[dept] ?? AppColors.primary;
                final icon =
                    _deptIcons[dept] ?? Icons.category;

                final isSelected =
                    eventService.selectedDepartment == dept;

                return GestureDetector(
                  onTap: () {
                    eventService.filterByDepartment(dept);
                  },
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : color.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : color.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: isSelected
                              ? Colors.white
                              : color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dept,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  eventService.selectedDepartment == 'All'
                      ? 'All Events'
                      : '${eventService.selectedDepartment} Events',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${eventService.filteredEvents.length} events',
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (eventService.filteredEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Text(
                    'No events for this department',
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    eventService.filteredEvents.length,
                itemBuilder: (context, index) {
                  final event =
                      eventService.filteredEvents[index];

                  return EventCard(
                    event: event,
                    onTap: () {},
                  );
                },
              ),
          ],
        ),
      ),
    );
  },
),
    );
  }
}
