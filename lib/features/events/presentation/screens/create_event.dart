import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteswap/features/home/presentation/pages/main_page.dart';

class CreateEventPage extends StatefulWidget {
  final String? groupId; // Optional: Link event to a specific community group

  const CreateEventPage({super.key, this.groupId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupIdController = TextEditingController();

  // Speakers & Banner Controllers
  final TextEditingController _speakerNameController = TextEditingController();
  final TextEditingController _speakerDescController = TextEditingController();
  final TextEditingController _speakerAvatarController =
      TextEditingController();
  final TextEditingController _bannerUrlController = TextEditingController();

  // Dropdown Selections
  String _selectedFormat = 'In-Person';
  String _selectedCategory = 'Workshop';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  final List<String> _formats = ['In-Person', 'Online', 'Hybrid'];
  final List<String> _categories = [
    'Workshop',
    'Seminar',
    'Hackathon',
    'Networking',
    'Conference',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.groupId != null) {
      _groupIdController.text = widget.groupId!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _groupIdController.dispose();
    _speakerNameController.dispose();
    _speakerDescController.dispose();
    _speakerAvatarController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  // Pick Date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Pick Time
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // Publish Event to Firebase
  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both a date and a time")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final String groupId = _groupIdController.text.trim();

      final Map<String, dynamic> eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'groupId': groupId,
        'date': Timestamp.fromDate(eventDateTime),
        'format': _selectedFormat,
        'category': _selectedCategory,
        'speakerName': _speakerNameController.text.trim().isEmpty
            ? 'Guest Speaker'
            : _speakerNameController.text.trim(),
        'speakerDescription': _speakerDescController.text.trim().isEmpty
            ? 'Event Host & Presenter'
            : _speakerDescController.text.trim(),
        'speakerAvatarUrl': _speakerAvatarController.text.trim().isEmpty
            ? 'https://picsum.photos/id/1027/200'
            : _speakerAvatarController.text.trim(),
        'bannerUrl': _bannerUrlController.text.trim().isEmpty
            ? 'https://picsum.photos/id/237/900/500'
            : _bannerUrlController.text.trim(),
        'filledSpots': 0,
        'maxSpots': 100,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('events').add(eventData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event published successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating event: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Create Event",
          style:
              TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Title
              _buildLabel("Event Title"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("e.g. Hackathon 2026"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),

              // Description
              _buildLabel("Description"),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration:
                    _inputDecoration("Provide details about the event..."),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Description is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // Location / Venue
              _buildLabel("Location / Venue"),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration("e.g. Innovation Lab or Online"),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Location is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // Format & Category Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Format"),
                        DropdownButtonFormField<String>(
                          value: _selectedFormat,
                          decoration: _inputDecoration(""),
                          items: _formats
                              .map((f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(f,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedFormat = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Category"),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration(""),
                          items: _categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedCategory = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date & Time Picker Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Date"),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: _pickerBoxDecoration(),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 18, color: brandPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate == null
                                      ? "Select Date"
                                      : DateFormat('MMM dd, yyyy')
                                          .format(_selectedDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedDate == null
                                        ? Colors.grey
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Time"),
                        InkWell(
                          onTap: _pickTime,
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: _pickerBoxDecoration(),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 18, color: brandPrimary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime == null
                                      ? "Select Time"
                                      : _selectedTime!.format(context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedTime == null
                                        ? Colors.grey
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Speaker Details Section
              const Divider(height: 24, thickness: 1),
              _buildLabel("Speaker Name (Optional)"),
              TextFormField(
                controller: _speakerNameController,
                decoration: _inputDecoration("e.g. Dr. Jane Doe"),
              ),
              const SizedBox(height: 12),

              _buildLabel("Speaker Bio (Optional)"),
              TextFormField(
                controller: _speakerDescController,
                maxLines: 2,
                decoration: _inputDecoration("Brief speaker bio..."),
              ),
              const SizedBox(height: 12),

              _buildLabel("Banner Image URL (Optional)"),
              TextFormField(
                controller: _bannerUrlController,
                decoration: _inputDecoration("https://..."),
              ),
              const SizedBox(height: 16),

              // Group ID
              _buildLabel("Group ID (Optional)"),
              TextFormField(
                controller: _groupIdController,
                decoration: _inputDecoration("Target Group / Community ID"),
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Publish Event",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF0F172A)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6366F1)),
      ),
    );
  }

  BoxDecoration _pickerBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );
  }
}
