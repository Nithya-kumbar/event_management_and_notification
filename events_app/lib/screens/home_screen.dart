// ============================================================
// home_screen.dart - Main Dashboard / Home Page
// Place this file at: lib/screens/home_screen.dart
// ============================================================
import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/college_logo_widget.dart';
import '../widgets/event_card.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Bottom nav bar active tab
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch events when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventService>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle bottom navigation bar taps
void _onNavTap(int index) {
  switch (index) {
    case 0:
      if (_currentIndex != 0) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      break;

    case 1:
      Navigator.pushReplacementNamed(context, '/calendar');
      break;

    case 2:
      Navigator.pushReplacementNamed(context, '/department-filter');
      break;

    case 3:
      Navigator.pushReplacementNamed(context, '/profile');
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom sliver app bar with college branding + greeting
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildAppBarBackground(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {
                    // TODO: Open notifications page
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Scrollable body content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 22),

                    // Event category chips
                    _buildCategoryChips(),
                    const SizedBox(height: 22),

                    // Featured / horizontal scroll events
                    _buildSectionHeader('Featured Events', onSeeAll: () {
                      Navigator.pushNamed(context, '/department-filter');
                    }),
                    const SizedBox(height: 12),
                    _buildHorizontalEvents(),
                    const SizedBox(height: 22),

                    // Department filter chips
                    _buildSectionHeader('By Department'),
                    const SizedBox(height: 10),
                    _buildDeptChips(),
                    const SizedBox(height: 16),

                    // Upcoming events vertical list
                    _buildSectionHeader('Upcoming Events', onSeeAll: () {
                      Navigator.pushNamed(context, '/calendar');
                    }),
                    const SizedBox(height: 12),
                    _buildEventList(),
                    const SizedBox(height: 80), // Bottom nav clearance
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // App bar background with gradient + greeting
  Widget _buildAppBarBackground() {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        final name = auth.currentUser?.name.split(' ').first ?? 'Student';
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  const CollegeLogoAppBar(),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Hello, $name! ',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'Discover what\'s happening on campus',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return Consumer<EventService>(
      builder: (context, eventService, _) {
        return TextField(
          controller: _searchController,
          onChanged: (v) => eventService.searchEvents(v),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search events, departments...',
            hintStyle:
                const TextStyle(color: AppColors.textLight, fontSize: 14),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textMedium, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.textMedium, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      eventService.resetFilters();
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        );
      },
    );
  }

  // Event category horizontal scroll chips
  Widget _buildCategoryChips() {
    return Consumer<EventService>(
      builder: (context, eventService, _) {
        return SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.eventCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = AppConstants.eventCategories[index];
              final isSelected = eventService.selectedCategory == cat;
              return GestureDetector(
                onTap: () => eventService.filterByCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Section header row with optional "See all" button
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  // Horizontal scrolling event cards
  Widget _buildHorizontalEvents() {
    return Consumer<EventService>(
      builder: (context, eventService, _) {
        if (eventService.isLoading) {
          return const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        }
print("filteredEvents = ${eventService.filteredEvents.length}");
        final events = eventService.filteredEvents;
        if (events.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No events found')),
          );
        }

        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length > 5 ? 5 : events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCardHorizontal(
                event: event,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/event-details',
                  arguments: event.toArgs(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Department filter chips
  Widget _buildDeptChips() {
    return Consumer<EventService>(
      builder: (context, eventService, _) {
        final departments = ['All', 'Computer Science', 'Electronics & ECE',
            'Mechanical', 'Civil Engineering', 'MBA', 'Cultural'];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: departments.map((dept) {
            final isSelected = eventService.selectedDepartment == dept;
            return GestureDetector(
              onTap: () => eventService.filterByDepartment(dept),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Text(
                  dept,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Vertical list of upcoming events
  Widget _buildEventList() {
    return Consumer<EventService>(
      builder: (context, eventService, _) {
        if (eventService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = eventService.filteredEvents;
        if (events.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(Icons.event_busy, size: 48, color: AppColors.textLight),
                const SizedBox(height: 12),
                const Text(
                  'No events for this filter.',
                  style: TextStyle(color: AppColors.textMedium),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // scroll handled by parent
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () => Navigator.pushNamed(
                context,
                '/event-details',
                arguments: event.toArgs(),
              ),
            );
          },
        );
      },
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Departments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
