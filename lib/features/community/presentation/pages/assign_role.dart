import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignRolePage extends StatefulWidget {
  final String groupId;
  final String targetUid;
  final String targetName;
  final String targetUsername;
  final String targetImageUrl;
  final String currentGroupCreatorUid;

  const AssignRolePage({
    super.key,
    required this.groupId,
    required this.targetUid,
    required this.targetName,
    required this.targetUsername,
    required this.targetImageUrl,
    required this.currentGroupCreatorUid,
  });

  @override
  State<AssignRolePage> createState() => _AssignRolePageState();
}

class _AssignRolePageState extends State<AssignRolePage> {
  String _selectedRole = 'Moderator';
  bool _pinMessages = true;
  bool _deleteMessages = true;
  bool _muteMembers = true;
  bool _addMembers = false;
  bool _changeSettings = false;
  bool _isSaving = false;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? "";
  bool get _isCurrentUserAdmin =>
      _currentUserId == widget.currentGroupCreatorUid;

  @override
  void initState() {
    super.initState();
    _loadExistingRoleAndPermissions();
  }

  Future<void> _loadExistingRoleAndPermissions() async {
    try {
      final memberDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('members')
          .doc(widget.targetUid)
          .get();

      if (memberDoc.exists && mounted) {
        final data = memberDoc.data();
        if (data != null) {
          setState(() {
            _selectedRole = data['role'] ?? 'Moderator';
            _pinMessages = data['canPinMessages'] ?? true;
            _deleteMessages = data['canDeleteMessages'] ?? true;
            _muteMembers = data['canMuteMembers'] ?? true;
            _addMembers = data['canAddMembers'] ?? false;
            _changeSettings = data['canChangeSettings'] ?? false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveRoleAndPermissions() async {
    if (!_isCurrentUserAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Only an Admin can change member roles.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('members')
          .doc(widget.targetUid)
          .update({
        'role': _selectedRole,
        'canPinMessages': _pinMessages,
        'canDeleteMessages': _deleteMessages,
        'canMuteMembers': _muteMembers,
        'canAddMembers': _addMembers,
        'canChangeSettings': _changeSettings,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Role and permissions updated successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E1B4B), size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Assign role',
          style: TextStyle(
              color: Color(0xFF1E1B4B),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRoleAndPermissions,
            child: Text(
              'Save',
              style: TextStyle(
                color:
                    _isCurrentUserAdmin ? const Color(0xFF6366F1) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Color(0xFFF3F4F6),
                    height: 2,
                    thickness: 5,
                  ),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFA7F3D0),
                          backgroundImage: widget.targetImageUrl.isNotEmpty
                              ? NetworkImage(widget.targetImageUrl)
                              : null,
                          child: widget.targetImageUrl.isEmpty
                              ? Text(
                                  widget.targetName.isNotEmpty
                                      ? widget.targetName[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                      fontSize: 20),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.targetName,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1B4B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.targetUsername,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0x991E1B4B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 25, 16, 15),
                    child: Text(
                      'CHOOSE ROLE',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B899F),
                          letterSpacing: 0.8),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        {
                          'role': 'Admin',
                          'desc':
                              'Full control — manage members, roles, settings and content.',
                          'asset': 'assets/community/admin.png'
                        },
                        {
                          'role': 'Moderator',
                          'desc':
                              'Can pin, delete messages and mute members. Cannot change settings.',
                          'asset': 'assets/community/moderator.png'
                        },
                        {
                          'role': 'Member',
                          'desc':
                              'Can send messages, react, and view shared files.',
                          'asset': 'assets/community/member.png'
                        },
                        {
                          'role': 'Read-only',
                          'desc': 'Can view messages but cannot send or react.',
                          'asset': 'assets/community/eye2.png'
                        },
                      ].map((item) {
                        bool isLast = item['role'] == 'Read-only';
                        return Column(
                          children: [
                            _buildRoleOption(
                                item['role']!, item['desc']!, item['asset']!),
                            if (!isLast)
                              const Divider(
                                  color: Color(0xFFF3F4F6),
                                  height: 1,
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  if (_selectedRole == 'Moderator') ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 10),
                      child: Text(
                        'MODERATOR PERMISSIONS',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B899F),
                            letterSpacing: 0.8),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildPermissionSwitch('Pin messages',
                              Icons.push_pin_outlined, _pinMessages, (val) {
                            setState(() => _pinMessages = val);
                          }),
                          const Divider(
                            color: Color(0xFFF3F4F6),
                            height: 1,
                            thickness: 2,
                          ),
                          _buildPermissionSwitch('Delete messages',
                              Icons.delete_outline, _deleteMessages, (val) {
                            setState(() => _deleteMessages = val);
                          }),
                          const Divider(
                            color: Color(0xFFF3F4F6),
                            height: 1,
                            thickness: 2,
                          ),
                          _buildPermissionSwitch('Mute members',
                              Icons.volume_mute_outlined, _muteMembers, (val) {
                            setState(() => _muteMembers = val);
                          }),
                          const Divider(
                            color: Color(0xFFF3F4F6),
                            height: 1,
                            thickness: 2,
                          ),
                          _buildPermissionSwitch('Add members',
                              Icons.person_add_outlined, _addMembers, (val) {
                            setState(() => _addMembers = val);
                          }),
                          const Divider(
                            color: Color(0xFFF3F4F6),
                            height: 1,
                            thickness: 2,
                          ),
                          _buildPermissionSwitch('Change group settings',
                              Icons.settings_outlined, _changeSettings, (val) {
                            setState(() => _changeSettings = val);
                          }),
                          const Divider(
                            color: Color(0xFFF3F4F6),
                            height: 2,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: (_isSaving || !_isCurrentUserAdmin)
                            ? null
                            : _saveRoleAndPermissions,
                        child: const Text(
                          'Save role',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleOption(String role, String description, String imagePath) {
    bool isSelected = _selectedRole == role;
    return InkWell(
      onTap: !_isCurrentUserAdmin
          ? null
          : () {
              setState(() {
                _selectedRole = role;
              });
            },
      child: Container(
        color: isSelected ? const Color(0xFFF5F3FF) : Colors.transparent,
        // Change vertical padding from 14 to 20 or 24 to increase row height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF8B899F), height: 1.3),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: role,
              groupValue: _selectedRole,
              activeColor: const Color(0xFF6366F1),
              onChanged: !_isCurrentUserAdmin
                  ? null
                  : (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch(
      String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF8B899F)),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6C84)),
      ),
      value: value,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF6366F1),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey.shade300,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      onChanged: _isCurrentUserAdmin ? onChanged : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
