import 'package:flutter/material.dart';
import '../../domain/entities/group.dart';
import '../../domain/repos/group_repo.dart';
import '../../../../core/di/injection.dart';

class CreateGroupPage extends StatefulWidget {
  final String collegeId;

  const CreateGroupPage({
    super.key,
    required this.collegeId,
  });

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final nameController = TextEditingController();

  final descController = TextEditingController();

  Future<void> createGroup() async {
    final repo = sl<GroupRepo>();

    await repo.createGroup(
      Group(
        id: '',
        name: nameController.text,
        collegeId: widget.collegeId,
        description: descController.text,
        memberCount: 1,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Group Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: createGroup,
              child: const Text(
                'Create',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
