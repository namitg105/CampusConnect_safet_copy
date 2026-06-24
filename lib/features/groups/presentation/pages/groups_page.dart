import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    Future.microtask(
      () => context.read<GroupCubit>().loadGroups(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Communities",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Join and chat with students",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<GroupCubit>().loadGroups();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<GroupCubit, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(
              child: CircularProgressIndicator(),
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.groups.length,
                itemBuilder: (_, index) {
                  return GroupCard(
                    group: state.groups[index],
                  );
                },
              ),
            );
          }

          if (state is GroupError) {
            return ErrorStateWidget(
              message: state.message,
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(Icons.add),
        label: const Text("Create"),
      ),
    );
  }
}
