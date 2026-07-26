/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateEventPage extends StatefulWidget {
  final String? groupId; // Optional: Link event to a specific community group

  const CreateEventPage({Key? key, this.groupId}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _groupIdController = TextEditingController();
  final TextEditingController _maxSpotsController =
      TextEditingController(text: "100");
  final TextEditingController _imageUrlController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

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
    _venueController.dispose();
    _groupIdController.dispose();
    _maxSpotsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Date Picker
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

  // Time Picker
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
      // Formatted date and time strings for EventDetailsPage UI
      final String formattedDate =
          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate!);

      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      final String formattedTime =
          DateFormat('h:mm a').format(combinedDateTime);

      // Schema mapped to match EventDetailsPage requirements exactly
      final Map<String, dynamic> eventData = {
        'title': _titleController.text.trim(),
        'about': _descriptionController.text.trim(),
        'venue': _venueController.text.trim(),
        'venueSubtitle': 'Campus Venue',
        'groupId': _groupIdController.text.trim(),
        'date': formattedDate,
        'dateSubtitle': DateFormat('MMM d').format(_selectedDate!),
        'time': formattedTime,
        'timeSubtitle': 'Standard Time',
        'timestamp': Timestamp.fromDate(combinedDateTime),
        'filledSpots': 0,
        'maxSpots': int.tryParse(_maxSpotsController.text.trim()) ?? 100,
        'participants': [],
        'imageUrl': _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
        'audience': 'All Campus Students',
        'audienceSubtitle': 'Open to all years',
        'tags': [
          {"label": "🎶 Event", "type": "purple"},
          {"label": "💸 Free Entry", "type": "green"},
          {"label": "🎂 All Years", "type": "orange"}
        ],
        'schedule': [
          {"title": "Gates Open", "time": formattedTime},
          {
            "title": "Event Start",
            "time": DateFormat('h:mm a')
                .format(combinedDateTime.add(const Duration(minutes: 30)))
          }
        ],
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('events').add(eventData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event published successfully!")),
        );
        Navigator.pop(context); // Return after creation
      }
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
    const Color brandPrimary = Color(0xFF7C4DFF);

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
              // Title Field
              _buildLabel("Event Title"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("e.g. Hackathon 2026"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),

              // Description Field
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

              // Venue / Location
              _buildLabel("Venue / Location"),
              TextFormField(
                controller: _venueController,
                decoration:
                    _inputDecoration("e.g. Innovation Lab or Main Auditorium"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Venue is required" : null,
              ),
              const SizedBox(height: 16),

              // Maximum Spots
              _buildLabel("Maximum Capacity"),
              TextFormField(
                controller: _maxSpotsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("100"),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Capacity is required"
                    : null,
              ),
              const SizedBox(height: 16),

              // Image URL Field
              _buildLabel("Banner Image URL (Optional)"),
              TextFormField(
                controller: _imageUrlController,
                decoration: _inputDecoration("https://images.unsplash.com/..."),
              ),
              const SizedBox(height: 16),

              // Group ID Field
              _buildLabel("Group ID (Optional)"),
              TextFormField(
                controller: _groupIdController,
                decoration: _inputDecoration("Target Group ID"),
              ),
              const SizedBox(height: 20),

              // Date & Time Row
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
                                Expanded(
                                  child: Text(
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
                                    overflow: TextOverflow.ellipsis,
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
                                Expanded(
                                  child: Text(
                                    _selectedTime == null
                                        ? "Select Time"
                                        : _selectedTime!.format(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _selectedTime == null
                                          ? Colors.grey
                                          : const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                              fontWeight: FontWeight.bold, fontSize: 16),
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
        borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
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
*/
