import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/admin_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<Map<String, dynamic>>> registrations;
  late Future<List<Map<String, dynamic>>> events;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    registrations = context.read<AdminService>().getRegistrations();
    events = context.read<AdminService>().getEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshRegistrations() async {
    setState(() {
      registrations = context.read<AdminService>().getRegistrations();
    });
  }

  Future<void> refreshEvents() async {
    setState(() {
      events = context.read<AdminService>().getEvents();
    });
  }

  Future<void> openEditor([Map<String, dynamic>? event]) async {
    final changed = await Navigator.pushNamed(
      context,
      "/edit-event",
      arguments: event, // null => create mode, map => edit mode
    );
    if (changed == true) {
      refreshEvents();
    }
  }

  Future<void> deleteEventConfirmed(int eventId) async {
    final result = await context.read<AdminService>().deleteEvent(eventId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "Deleted")),
    );
    refreshEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
  controller: _tabController,
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white70,
  indicatorColor: Colors.white,
  tabs: const [
    Tab(text: "Registrations"),
    Tab(text: "Manage Events"),
  ],
),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshRegistrations();
              refreshEvents();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AdminService>().logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistrationsTab(),
          _buildEventsTab(),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton.extended(
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  onPressed: () => openEditor(),
  icon: const Icon(Icons.add),
  label: const Text("Add Event"),
);
        },
      ),
    );
  }

  Widget _buildRegistrationsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: registrations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No registrations found"));
        }

        final list = snapshot.data!;

        return RefreshIndicator(
          onRefresh: refreshRegistrations,
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final reg = list[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reg["eventName"] ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text("Student : ${reg["userName"]}"),
                      Text("USN : ${reg["userUsn"]}"),
                      Text("Email : ${reg["userEmail"]}"),
                      Text("Department : ${reg["userDepartment"]}"),
                      const Divider(),
                      Text("Date : ${reg["eventDate"]}"),
                      Text("Time : ${reg["eventTime"]}"),
                      Text("Status : ${reg["status"]}"),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () async {
                              final result = await context
                                  .read<AdminService>()
                                  .deleteRegistration(reg["registrationId"]);
                              if (result["success"] == true) {
                                refreshRegistrations();
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text("Remove"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No events found"));
        }

        final list = snapshot.data!;

        return RefreshIndicator(
          onRefresh: refreshEvents,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (_, index) {
              final ev = list[index];
              final imageUrl = ev["image_url"];
              final fileType = ev["fileType"];

              return Dismissible(
                key: ValueKey(ev["id"]),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Delete Event"),
                      content: const Text(
                          "This will also remove it from student view. Continue?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) => deleteEventConfirmed(ev["id"]),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => openEditor(ev),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null &&
                            imageUrl.toString().isNotEmpty &&
                            fileType == "IMAGE")
                          Image.network(
                            "${AppConstants.fileBaseUrl}$imageUrl",
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        if (imageUrl != null &&
                            imageUrl.toString().isNotEmpty &&
                            fileType == "PDF")
                          Container(
                            height: 60,
                            color: Colors.red.shade50,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                const Text("Brochure attached"),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => launchUrl(
                                    Uri.parse(
                                        "${AppConstants.fileBaseUrl}$imageUrl"),
                                  ),
                                  child: const Text("View"),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ev["event_name"] ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 6),
                              Text("Department : ${ev["department"] ?? "-"}"),
                              Text("Date : ${ev["event_date"] ?? "-"}"),
                              Text("Time : ${ev["event_time"] ?? "-"}"),
                              Text("Location : ${ev["location"] ?? "-"}"),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => openEditor(ev),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text("Edit"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}