import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminCreateEventPage extends StatefulWidget {
  const AdminCreateEventPage({Key? key}) : super(key: key);

  @override
  State<AdminCreateEventPage> createState() => _AdminCreateEventPageState();
}

class _AdminCreateEventPageState extends State<AdminCreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _venueSubtitleController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _maxSpotsController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();

  // Date & Time Values
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Dynamic Schedule List
  final List<Map<String, String>> _scheduleList = [];
  final TextEditingController _scheduleTitleController =
      TextEditingController();
  final TextEditingController _scheduleTimeController = TextEditingController();

  // Tag Selection State
  final List<Map<String, String>> _availableTags = [
    {"label": "🎶 Event", "type": "purple"},
    {"label": "💸 Free Entry", "type": "green"},
    {"label": "🎂 All Years", "type": "orange"},
    {"label": "💻 Tech", "type": "blue"},
  ];
  final List<Map<String, String>> _selectedTags = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _venueSubtitleController.dispose();
    _aboutController.dispose();
    _imageUrlController.dispose();
    _maxSpotsController.dispose();
    _audienceController.dispose();
    _scheduleTitleController.dispose();
    _scheduleTimeController.dispose();
    super.dispose();
  }

  // --- Pickers ---
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // --- Schedule Helper ---
  void _addScheduleItem() {
    if (_scheduleTitleController.text.trim().isNotEmpty &&
        _scheduleTimeController.text.trim().isNotEmpty) {
      setState(() {
        _scheduleList.add({
          "title": _scheduleTitleController.text.trim(),
          "time": _scheduleTimeController.text.trim(),
        });
        _scheduleTitleController.clear();
        _scheduleTimeController.clear();
      });
    }
  }

  // --- Submit to Firestore ---
  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an event date.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String formattedDate =
          "${_getMonthName(_selectedDate!.month)} ${_selectedDate!.day}, ${_selectedDate!.year}";
      final String formattedTime =
          _selectedTime != null ? _selectedTime!.format(context) : "10:00 AM";

      final eventData = {
        'title': _titleController.text.trim(),
        'date': formattedDate,
        'dateSubtitle':
            "${_getDayName(_selectedDate!.weekday)}, $formattedTime",
        'time': formattedTime,
        'timeSubtitle': 'GMT+5:30',
        'venue': _venueController.text.trim(),
        'venueSubtitle': _venueSubtitleController.text.trim().isEmpty
            ? 'Main Campus'
            : _venueSubtitleController.text.trim(),
        'about': _aboutController.text.trim(),
        'filledSpots': 0,
        'maxSpots': int.tryParse(_maxSpotsController.text.trim()) ?? 100,
        'audience': _audienceController.text.trim().isEmpty
            ? 'All Students'
            : _audienceController.text.trim(),
        'audienceSubtitle': 'Open to Year 1-4',
        'imageUrl': _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800'
            : _imageUrlController.text.trim(),
        'participants': [],
        'schedule': _scheduleList,
        'tags': _selectedTags.isEmpty
            ? [
                {"label": "🎶 Event", "type": "purple"},
                {"label": "💸 Free Entry", "type": "green"}
              ]
            : _selectedTags,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('events').add(eventData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event Created Successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating event: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getDayName(int day) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Create Event",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Event Details"),
              const SizedBox(height: 10),

              // Event Title
              _buildTextField(
                controller: _titleController,
                label: "Event Title",
                hint: "e.g. Tech Symposium 2026",
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 12),

              // Date & Time Selectors Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today,
                          size: 14, color: Color(0xFF7C4DFF)),
                      label: Text(
                        _selectedDate == null
                            ? "Pick Date"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time,
                          size: 14, color: Color(0xFF7C4DFF)),
                      label: Text(
                        _selectedTime == null
                            ? "Pick Time"
                            : _selectedTime!.format(context),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Venue Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _venueController,
                      label: "Venue Name",
                      hint: "e.g. Anna Auditorium",
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _venueSubtitleController,
                      label: "Venue Subtitle",
                      hint: "e.g. Main Campus",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Capacity & Audience
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _maxSpotsController,
                      label: "Max Spots",
                      hint: "100",
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _audienceController,
                      label: "Target Audience",
                      hint: "e.g. All Students",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Image URL
              _buildTextField(
                controller: _imageUrlController,
                label: "Banner Image URL",
                hint: "https://...",
              ),

              const SizedBox(height: 12),

              // About Text
              _buildTextField(
                controller: _aboutController,
                label: "About Event Description",
                hint: "Describe the event agenda, perks, etc.",
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("Tags"),
              const SizedBox(height: 8),

              // Tags Selector
              Wrap(
                spacing: 8,
                children: _availableTags.map((tag) {
                  final isSelected =
                      _selectedTags.any((t) => t['label'] == tag['label']);
                  return FilterChip(
                    label: Text(tag['label']!,
                        style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.black87)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF7C4DFF),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags
                              .removeWhere((t) => t['label'] == tag['label']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("Add Schedule / Agenda"),
              const SizedBox(height: 8),

              // Schedule Add Controls
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _scheduleTitleController,
                      label: "Session Title",
                      hint: "Keynote",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      controller: _scheduleTimeController,
                      label: "Time",
                      hint: "10:00 AM",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: Color(0xFF7C4DFF), size: 28),
                    onPressed: _addScheduleItem,
                  )
                ],
              ),

              // Display Added Schedule Items
              if (_scheduleList.isNotEmpty) ...[
                const SizedBox(height: 10),
                ..._scheduleList.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return Card(
                    elevation: 0,
                    color: Colors.grey[100],
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      title: Text(item['title']!,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item['time']!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 16, color: Colors.redAccent),
                            onPressed: () {
                              setState(() => _scheduleList.removeAt(idx));
                            },
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "PUBLISH EVENT",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
        ),
      ),
    );
  }
}
