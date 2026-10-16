import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Widgets/botnav.dart';
import '../../Widgets/community_page.dart';
import '../../Widgets/group_widgets.dart';
import '../bloc/groups/groups_bloc.dart';
import '../bloc/membership/membership_bloc.dart';
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
      if (mounted) {
        context.read<GroupsBloc>().add(const GroupsWatchStarted());
      }
    });
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateGroupPage(
          collegeId: "",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF6366F1);
    const Color bgSurface = Color(0xFFF8FAFC);

    return BlocListener<MembershipBloc, MembershipState>(
      listenWhen: (p, c) => p.outcomeId != c.outcomeId,
      listener: (context, state) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.outcome!.message))),
      child: Scaffold(
      backgroundColor: bgSurface,
      extendBody: true, // lets content scroll behind the floating nav bar

      body: SafeArea(
        bottom: false,
        child: BlocBuilder<GroupsBloc, GroupState>(
          builder: (context, state) {
            if (state is GroupLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: brandPrimary,
                  strokeWidth: 3,
                ),
              );
            }

            if (state is GroupError) {
              return Center(
                child: ErrorStateWidget(
                  message: state.message,
                ),
              );
            }

            if (state is GroupLoaded) {
              // Always display CommunitiesPage regardless of whether state.groups is empty or not.
              // CommunitiesPage handles empty states internally with neat cards and keeps full UI intact.
              return RefreshIndicator(
                color: brandPrimary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<GroupsBloc>().add(const GroupsWatchStarted());
                },
                child: CommunitiesPage(
                  groups: state.groups,
                  onCreateCommunity: () => _navigateToCreateGroup(context),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    ),
    );
  }
}
