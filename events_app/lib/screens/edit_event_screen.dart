import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/admin_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final categoryController = TextEditingController();
  final organizerController = TextEditingController();
  final registrationLinkController = TextEditingController();

  final List<String> departments = [
    "Computer Science",
    "Information Science",
    "Electronics & Communication",
    "Mechanical",
    "Civil",
    "Electrical",
    "MBA",
    "MCA",
  ];

  String? selectedDepartment;

  String? uploadedUrl; // maps to image_url
  String? uploadedFileType; // "IMAGE" or "PDF" -> fileType
  bool uploading = false;

  DateTime? registrationDueDate;

  bool loading = false;
  bool initialized = false;

  int? eventId; // null => create mode, non-null => edit mode
  bool get isEditMode => eventId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        eventId = args["id"] as int?;
        nameController.text = args["event_name"] ?? "";
        descriptionController.text = args["description"] ?? "";
        selectedDepartment = args["department"];
        dateController.text = args["event_date"] ?? "";
        timeController.text = args["event_time"] ?? "";
        locationController.text = args["location"] ?? "";
        categoryController.text = args["category"] ?? "";
        organizerController.text = args["organizer"] ?? "";
        registrationLinkController.text = args["registration_link"] ?? "";
        uploadedUrl = args["image_url"];
        uploadedFileType = args["fileType"];

        final dueDateStr = args["registration_due_date"];
        if (dueDateStr != null) {
          registrationDueDate = DateTime.tryParse(dueDateStr.toString());
        }
      }
      initialized = true;
    }
  }

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final sizeInBytes = await file.length();
    if (sizeInBytes > 2 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File must be under 2MB")),
      );
      return;
    }

    setState(() => uploading = true);

    final result2 = await context.read<AdminService>().uploadEventFile(file);

    setState(() => uploading = false);

    if (result2["success"] == true) {
      setState(() {
        uploadedUrl = result2["url"];
        uploadedFileType = result2["fileType"];
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result2["message"] ?? "Upload failed")),
      );
    }
  }

  Future<void> pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: registrationDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => registrationDueDate = picked);
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final payload = {
      "event_name": nameController.text,
      "description": descriptionController.text,
      "department": selectedDepartment ?? "",
      "event_date": dateController.text,
      "event_time": timeController.text,
      "location": locationController.text,
      "category": categoryController.text,
      "organizer": organizerController.text,
      "registration_link": registrationLinkController.text,
      "image_url": uploadedUrl ?? "",
      "file_type": uploadedFileType ?? "",
      "registration_due_date": registrationDueDate != null
          ? "${registrationDueDate!.year}-${registrationDueDate!.month.toString().padLeft(2, '0')}-${registrationDueDate!.day.toString().padLeft(2, '0')}"
          : null,
    };

    final adminService = context.read<AdminService>();
    final result = isEditMode
        ? await adminService.updateEvent(eventId!, payload)
        : await adminService.createEvent(payload);

    setState(() => loading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "Done")),
    );

    if (result["success"] == true) {
      Navigator.pop(context, true); // tell dashboard to refresh
    }
  }

  Widget box(TextEditingController controller, String label,
      {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => (v == null || v.isEmpty) ? "Required" : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDepartmentDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: selectedDepartment,
        decoration: InputDecoration(
          labelText: "Department",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: departments
            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
            .toList(),
        validator: (v) => v == null ? "Required" : null,
        onChanged: (v) => setState(() => selectedDepartment = v),
      ),
    );
  }

  Widget buildDueDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: pickDueDate,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Registration Due Date (optional)",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: registrationDueDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () =>
                        setState(() => registrationDueDate = null),
                  )
                : const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            registrationDueDate != null
                ? "${registrationDueDate!.year}-${registrationDueDate!.month.toString().padLeft(2, '0')}-${registrationDueDate!.day.toString().padLeft(2, '0')}"
                : "Defaults to event date",
            style: TextStyle(
              color: registrationDueDate != null ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilePicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Event Image / Brochure (JPG or PDF, max 2MB)",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (uploadedUrl != null &&
              uploadedUrl!.isNotEmpty &&
              uploadedFileType == "IMAGE")
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "${AppConstants.fileBaseUrl}$uploadedUrl",
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Text("Preview unavailable"),
              ),
            ),
          if (uploadedUrl != null &&
              uploadedUrl!.isNotEmpty &&
              uploadedFileType == "PDF")
            Row(
              children: const [
                Icon(Icons.picture_as_pdf, color: Colors.red),
                SizedBox(width: 8),
                Text("PDF brochure attached"),
              ],
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: uploading ? null : pickAndUploadFile,
            icon: uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: Text(
                (uploadedUrl == null || uploadedUrl!.isEmpty)
                    ? "Choose File"
                    : "Replace File"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Event" : "Add Event"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              box(nameController, "Event Name"),
              box(descriptionController, "Description", required: false),
              buildDepartmentDropdown(),
              box(dateController, "Event Date (YYYY-MM-DD)"),
              buildDueDatePicker(),
              box(timeController, "Event Time"),
              box(locationController, "Location"),
              box(categoryController, "Category"),
              box(organizerController, "Organizer"),
              box(registrationLinkController, "Registration Link",
                  required: false),
              buildFilePicker(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: loading ? null : save,
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(isEditMode ? "Update Event" : "Create Event"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}