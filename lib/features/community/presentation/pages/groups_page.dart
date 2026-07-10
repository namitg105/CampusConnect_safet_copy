import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Widgets/community_page.dart';
import '../../Widgets/group_widgets.dart';
import '../cubits/group_cubit.dart';
import '../cubits/group_states.dart';
import 'create_group_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GroupCubit>().loadGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff6139ED),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Create"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateGroupPage(
                collegeId: "",
              ),
            ),
          );
        },
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is GroupError) {
            return ErrorStateWidget(
              message: state.message,
            );
          }

          if (state is GroupLoaded) {
            if (state.groups.isEmpty) {
              return const EmptyGroupsWidget();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<GroupCubit>().loadGroups();
              },
              child: CommunitiesPage(
                groups: state.groups,
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
