import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'backend/note_models.dart';
import 'noteswap_controller.dart';

class UploadNotesScreen extends StatefulWidget {
  const UploadNotesScreen({super.key});

  @override
  State<UploadNotesScreen> createState() => _UploadNotesScreenState();
}

class _UploadNotesScreenState extends State<UploadNotesScreen> {
  static const Color _background = Color(0xFFF7F6FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _accentDeep = Color(0xFF4F46E5);
  static const Color _textDark = Color(0xFF1F2747);
  static const Color _textMuted = Color(0xFF757575);
  static const Color _borderColor = Color(0xFFF5F5F5);
  static const Color _toggleBg = Color(0xFFEEEEF3);
  static const Color _shadowColor = Color(0x0A000000);

  bool _isFree = true;
  int _charCount = 0;
  final ImagePicker _picker = ImagePicker();
  final List<XFile?> _previewImages = List<XFile?>.filled(3, null);

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _fileName;
  String? _filePath;
  int _fileSize = 0;
  bool _uploading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _courseCodeController.dispose();
    _semesterController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _upload() async {
    final String subject = _subjectController.text.trim();
    final String fileName = _fileName ?? '';
    final String filePath = _filePath ?? '';

    if (fileName.isEmpty || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the subject name')),
      );
      return;
    }

    final String priceText = _priceController.text.trim();
    final num price =
        _isFree ? 0 : (double.tryParse(priceText) ?? 0);

    final data = NoteUploadData(
      title: subject,
      subject: subject,
      courseCode: _courseCodeController.text.trim(),
      semester: _semesterController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      isFree: _isFree,
      fileName: fileName,
      filePath: filePath,
      fileSize: _fileSize,
      previewPaths: _previewImages
          .whereType<XFile>()
          .map((f) => f.path)
          .toList(),
    );

    setState(() => _uploading = true);
    try {
      await Get.find<NoteswapController>().upload(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
    } on StorageCreditException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fire storage credits ended'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _resetForm() {
    _subjectController.clear();
    _courseCodeController.clear();
    _semesterController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _charCount = 0;
      _isFree = true;
      _fileName = null;
      _filePath = null;
      _fileSize = 0;
      for (var i = 0; i < _previewImages.length; i++) {
        _previewImages[i] = null;
      }
    });
  }

  Future<void> _pickPreviewImage(int index) async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final ext = image.name.split('.').last.toLowerCase();
      if (!['png', 'jpg', 'jpeg'].contains(ext)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only PNG or JPG images are allowed'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!mounted) return;
      setState(() => _previewImages[index] = image);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removePreviewImage(int index) {
    setState(() => _previewImages[index] = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _UploadHeader(),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UploadPdfSection(
                        onPicked: (name, path, size) => setState(() {
                          _fileName = name;
                          _filePath = path;
                          _fileSize = size;
                        }),
                        onCleared: () => setState(() {
                          _fileName = null;
                          _filePath = null;
                          _fileSize = 0;
                        }),
                      ),
                      const SizedBox(height: 18),
                      _FormField(
                        icon: Icons.book_outlined,
                        label: 'Subject',
                        hint: 'e.g. Data Structures',
                        controller: _subjectController,
                      ),
                      const SizedBox(height: 18),
                      _FormField(
                        icon: Icons.tag,
                        label: 'Course Code',
                        hint: 'e.g. CS-204',
                        controller: _courseCodeController,
                      ),
                      const SizedBox(height: 18),
                      _FormField(
                        icon: Icons.school_outlined,
                        label: 'Semester',
                        hint: 'e.g. 3rd Semester',
                        controller: _semesterController,
                      ),
                      const SizedBox(height: 18),
                      _DescriptionField(
                        charCount: _charCount,
                        controller: _descriptionController,
                        onChanged: (value) =>
                            setState(() => _charCount = value.length),
                      ),
                      const SizedBox(height: 18),
                      _PreviewUploadSection(
                        images: _previewImages,
                        onPick: _pickPreviewImage,
                        onRemove: _removePreviewImage,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _FormField(
                              icon: Icons.currency_rupee,
                              label: 'Price',
                              hint: '0',
                              fieldKey: const ValueKey('price'),
                              numberOnly: true,
                              controller: _priceController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PriceToggle(
                              isFree: _isFree,
                              onChanged: (value) =>
                                  setState(() => _isFree = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ActionButtons(
                        uploading: _uploading,
                        onUpload: _upload,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadHeader extends StatelessWidget {
  const _UploadHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Notes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _UploadNotesScreenState._textDark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Share your notes with the community',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _UploadNotesScreenState._textMuted,
                ),
              ),
            ],
          ),
        ),
        Image.asset(
          'assets/chat_assets/upload-image-png.png',
          width: 150,
          height: 110,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _UploadPdfSection extends StatefulWidget {
  final void Function(String name, String path, int size) onPicked;
  final VoidCallback onCleared;

  const _UploadPdfSection({
    required this.onPicked,
    required this.onCleared,
  });

  @override
  State<_UploadPdfSection> createState() => _UploadPdfSectionState();
}

class _UploadPdfSectionState extends State<_UploadPdfSection> {
  static const List<String> _allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
  ];

  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: _allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final path = file.path;
    if (path == null) return;
    if (!mounted) return;
    setState(() => _fileName = file.name);
    widget.onPicked(file.name, path, file.size);
  }

  void _clearFile() {
    setState(() => _fileName = null);
    widget.onCleared();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Upload File'),
        const SizedBox(height: 12),
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: _UploadNotesScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: _UploadNotesScreenState._accent,
            ),
            child:
                _fileName == null ? _buildPlaceholder() : _buildFileSelected(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _UploadNotesScreenState._accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.picture_as_pdf,
            color: _UploadNotesScreenState._accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Click to upload',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _UploadNotesScreenState._textDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'PDF, PPT or Word • Max 25 MB',
          style: TextStyle(
            fontSize: 12,
            color: _UploadNotesScreenState._textMuted,
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  _UploadNotesScreenState._accent,
                  _UploadNotesScreenState._accentDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Browse',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Max size: 25 MB',
          style: TextStyle(
            fontSize: 10,
            color: _UploadNotesScreenState._textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelected() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _UploadNotesScreenState._accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: _UploadNotesScreenState._accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _fileName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _UploadNotesScreenState._textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickFile,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _UploadNotesScreenState._accent,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _clearFile,
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _UploadNotesScreenState._textDark,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Key? fieldKey;
  final bool numberOnly;
  final TextEditingController? controller;

  const _FormField({
    required this.icon,
    required this.label,
    required this.hint,
    this.fieldKey,
    this.numberOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _UploadNotesScreenState._borderColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: _UploadNotesScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: _UploadNotesScreenState._textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: fieldKey,
                  controller: controller,
                  keyboardType: numberOnly ? TextInputType.number : null,
                  inputFormatters: numberOnly
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: _UploadNotesScreenState._textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  final int charCount;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const _DescriptionField({
    required this.charCount,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Description'),
        const SizedBox(height: 8),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _UploadNotesScreenState._borderColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: _UploadNotesScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Write a short description...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: _UploadNotesScreenState._textMuted,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '$charCount/500',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _UploadNotesScreenState._textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewUploadSection extends StatelessWidget {
  final List<XFile?> images;
  final ValueChanged<int> onPick;
  final ValueChanged<int> onRemove;

  const _PreviewUploadSection({
    required this.images,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Preview Upload'),
        const SizedBox(height: 8),
        const Text(
          'Add up to 3 images (PNG / JPG)',
          style: TextStyle(
            fontSize: 12,
            color: _UploadNotesScreenState._textMuted,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              Expanded(
                child: _PreviewSlot(
                  image: images[i],
                  onTap: () => onPick(i),
                  onRemove: () => onRemove(i),
                ),
              ),
              if (i != 2) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _PreviewSlot extends StatelessWidget {
  final XFile? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PreviewSlot({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: _UploadNotesScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: image == null
              ? CustomPaint(
                  painter: _DashedBorderPainter(
                    color: _UploadNotesScreenState._accent,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: _UploadNotesScreenState._accent,
                        size: 26,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _UploadNotesScreenState._accent,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(image!.path),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PriceToggle extends StatelessWidget {
  final bool isFree;
  final ValueChanged<bool> onChanged;

  const _PriceToggle({required this.isFree, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Type'),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _UploadNotesScreenState._toggleBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: _UploadNotesScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _ToggleOption(
                  label: 'Free',
                  selected: isFree,
                  onTap: () => onChanged(true),
                ),
              ),
              Expanded(
                child: _ToggleOption(
                  label: 'Paid',
                  selected: !isFree,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? _UploadNotesScreenState._accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _UploadNotesScreenState._textMuted,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool uploading;
  final VoidCallback onUpload;

  const _ActionButtons({
    required this.uploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: uploading ? null : onUpload,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    _UploadNotesScreenState._accent,
                    _UploadNotesScreenState._accentDeep,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: uploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
