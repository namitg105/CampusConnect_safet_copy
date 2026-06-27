import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noteswap/features/auth/domain/entities/app_user.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:noteswap/features/auth/presentation/cubits/auth_states.dart';
import 'package:noteswap/features/posts/presentation/controllers/post_controller.dart';
import 'package:noteswap/features/posts/presentation/pages/create_post_page.dart';
import 'package:noteswap/features/posts/presentation/pages/post_detail_page.dart';
import 'package:noteswap/features/posts/presentation/pages/user_profile_screen.dart';
import 'package:noteswap/features/posts/presentation/widgets/post_card.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/features/posts/data/post_repo_impl.dart';
import 'package:noteswap/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_comment_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/downvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_feed_by_tag_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_top_voted_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/upvote_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_votes_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:noteswap/features/posts/domain/usecases/get_user_liked_comments_usecase.dart';

/// Day 4: Campus Feed Screen
/// Displays all posts from your college sorted by Newest or Top Voted
/// With tag filtering and voting functionality
class CampusFeedScreen extends StatefulWidget {
  const CampusFeedScreen({Key? key}) : super(key: key);

  @override
  State<CampusFeedScreen> createState() => _CampusFeedScreenState();
}

class _CampusFeedScreenState extends State<CampusFeedScreen> {
  late PostController postController;
  final LightModeController lightModeController = Get.find<LightModeController>();

  // List of available tags for filtering
  final List<String> tags = [
    'All',
    'Badminton',
    'Seniors',
    'ExamHelp',
    'General',
    'Events',
    'Study',
  ];

  @override
  void initState() {
    super.initState();
    _initializePostController();
  }

  void _initializePostController() {
    // Day 4: Initialize PostController with all required use cases
    final postRepo = PostRepoImpl();
    postController = PostController(
      createPostUseCase: CreatePostUseCase(repository: postRepo),
      getFeedUseCase: GetFeedUseCase(repository: postRepo),
      getFeedByTagUseCase: GetFeedByTagUseCase(repository: postRepo),
      getTopVotedPostsUseCase: GetTopVotedPostsUseCase(repository: postRepo),
      upvotePostUseCase: UpvotePostUseCase(repository: postRepo),
      downvotePostUseCase: DownvotePostUseCase(repository: postRepo),
      addCommentUseCase: AddCommentUseCase(repository: postRepo),
      getCommentsUseCase: GetCommentsUseCase(repository: postRepo),
      deleteCommentUseCase: DeleteCommentUseCase(repository: postRepo),
      toggleCommentLikeUseCase: ToggleCommentLikeUseCase(repository: postRepo),
      getUserVotesUseCase: GetUserVotesUseCase(repository: postRepo),
      deletePostUseCase: DeletePostUseCase(repository: postRepo),
      getUserLikedCommentsUseCase: GetUserLikedCommentsUseCase(repository: postRepo),
    );

    // Load feed when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        postController.loadFeed(authState.user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            body: Center(
              child: Text(
                'Please login to view the feed',
                style: TextStyle(
                  color: lightModeController.isLightMode.value
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            ),
          );
        }

        final currentUser = authState.user;

        return Scaffold(
          backgroundColor: lightModeController.isLightMode.value
              ? Colors.white
              : Colors.black,
          appBar: AppBar(
            backgroundColor: lightModeController.isLightMode.value
                ? Colors.black
                : Colors.white,
            title: Text(
              'Campus Feed',
              style: TextStyle(
                color: lightModeController.isLightMode.value
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => postController.loadFeed(currentUser),
                icon: Icon(
                  Icons.refresh,
                  color: lightModeController.isLightMode.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Get.to(() => UserProfileScreen(user: currentUser)),
                icon: Icon(
                  Icons.person_outline,
                  color: lightModeController.isLightMode.value
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
          body: Obx(
            () => Column(
              children: [
                // Day 3: Tab Bar for sorting (Newest / Top Voted)
                Container(
                  color: lightModeController.isLightMode.value
                      ? Colors.white
                      : const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTabButton(
                        label: 'Newest',
                        isActive: postController.selectedTab.value == 'Newest',
                        onTap: () => postController.changeTab('Newest', currentUser),
                      ),
                      _buildTabButton(
                        label: 'Top Voted',
                        isActive: postController.selectedTab.value == 'Top Voted',
                        onTap: () =>
                            postController.changeTab('Top Voted', currentUser),
                      ),
                    ],
                  ),
                ),

                // Day 3: Tag Filter Chips
                Container(
                  color: lightModeController.isLightMode.value
                      ? Colors.white
                      : const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    child: Row(
                      children: postController.availableTags.map((tag) {
                        final isSelected = postController.selectedTag.value == tag;
                        return GestureDetector(
                          onTap: () =>
                              postController.filterByTag(tag, currentUser),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6139ED)
                                  : (lightModeController.isLightMode.value
                                      ? Colors.grey[200]
                                      : Colors.grey[800]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (lightModeController.isLightMode.value
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Day 4: Posts List or Loading/Empty State
                Expanded(
                  child: postController.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6139ED),
                          ),
                        )
                      : postController.errorMessage.isNotEmpty
                          ? Center(
                              child: Text(
                                postController.errorMessage.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: lightModeController.isLightMode.value
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            )
                          : postController.posts.isEmpty
                              ? Center(
                                  child: Text(
                                    'No posts yet.\nBe the first to share!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          lightModeController.isLightMode.value
                                              ? Colors.grey[600]
                                              : Colors.grey[400],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: postController.posts.length,
                                  itemBuilder: (context, index) {
                                    final post = postController.posts[index];
                                    return PostCard(
                                      post: post,
                                      onTap: () => Get.to(() => PostDetailPage(
                                        post: post,
                                        controller: postController,
                                        currentUser: currentUser,
                                      )),
                                      onProfileTap: () => Get.to(() => UserProfileScreen(user: AppUser(
                                        uid: post.authorId,
                                        email: '',
                                        name: post.authorName,
                                        collegeId: post.collegeId,
                                      ))),
                                      onUpvote: () =>
                                          postController.toggleUpvote(
                                        post.id,
                                        currentUser.uid,
                                        currentUser,
                                      ),
                                      onDownvote: () =>
                                          postController.toggleDownvote(
                                        post.id,
                                        currentUser.uid,
                                        currentUser,
                                      ),
                                      onDelete: post.authorId == currentUser.uid
                                          ? () => _confirmDeletePost(post.id, currentUser)
                                          : null,
                                      isLightMode: lightModeController
                                          .isLightMode.value,
                                      isUpvoted: postController.getUserVote(post.id) == 1,
                                      isDownvoted: postController.getUserVote(post.id) == -1,
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),

          // Day 4: FAB to create new post
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF6139ED),
            onPressed: () => Get.to(() => CreatePostPage(
              controller: postController,
              currentUser: currentUser,
            )),
            icon: const Icon(Icons.add),
            label: const Text(
              'New Post',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePost(String postId, AppUser currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await postController.removePost(postId, currentUser);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Helper widget for sorting tab buttons
  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6139ED)
              : (lightModeController.isLightMode.value
                  ? Colors.grey[200]
                  : Colors.grey[800]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : (lightModeController.isLightMode.value
                    ? Colors.black
                    : Colors.white),
          ),
        ),
      ),
    );
  }
}
