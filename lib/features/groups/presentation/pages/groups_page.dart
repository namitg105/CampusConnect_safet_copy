import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteswap/features/chat/presentation/pages/chat_page.dart';

import '../cubits/group_cubit.dart';
import '../cubits/group_states.dart';
import '../../domain/entities/group.dart';

class GroupsPage extends StatelessWidget {
  final String collegeId;

  const GroupsPage({
    super.key,
    required this.collegeId,
  });

  @override
  Widget build(BuildContext context) {
    context.read<GroupCubit>().loadGroups(collegeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GroupLoaded) {
            return ListView.builder(
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final Group group = state.groups[index];

                return Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text(group.description),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${group.memberCount}'),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () async {
                            await context
                                .read<GroupCubit>()
                                .joinGroup(group.id);
                          },
                          child: const Text('Join'),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            groupId: group.id,
                            groupName: group.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
