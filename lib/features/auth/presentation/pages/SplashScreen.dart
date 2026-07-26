import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:noteswap/features/auth/presentation/pages/auth_page.dart';
import 'package:noteswap/features/posts/domain/entities/post_entity.dart';

import 'package:noteswap/features/posts/domain/repos/post_repo.dart';
import 'package:noteswap/features/posts/domain/entities/comment_entity.dart';
class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LightModeController lightModeController =
      Get.put(LightModeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          const SizedBox.expand(),
          Positioned(
              top: 5,
              left: 10,
              width: 200,
              child: Image.asset("assets/Heading.png")),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.12,
            right: 0,
            left: 0,
            child: Image.asset(
              "assets/Splash.png",
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 19.0, vertical: 19.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    "Connect.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    "Collaborate.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    "Grow Together",
                    style: TextStyle(
                      color: Color(0xFF6139ED),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "The all-in-one student\nCommunication Platform\nfor clubs, courses, and\ncampus communities",
                    style: TextStyle(
                      color: Color(0xFF4A4A68),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                        },
                        child: Image.asset(
                          "assets/Button.png",
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => const AuthPage());
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFF6139ED),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MockPostRepo implements PostRepo {
  @override
  Future<void> createPost(PostEntity post) async {}

  @override
  Future<List<PostEntity>> getCollegeFeed(String collegeId) async => [];

  @override
  Future<List<PostEntity>> getCollegeFeedByTag(String collegeId, String tag) async => [];

  @override
  Future<List<PostEntity>> getTopVotedPosts(String collegeId) async => [];

  @override
  Future<List<PostEntity>> getNewestPosts(String collegeId) async => [];

  @override
  Future<void> upvotePost(String postId, String userId) async {}

  @override
  Future<void> downvotePost(String postId, String userId) async {}

  @override
  Future<void> removeVote(String postId, String userId) async {}

  @override
  Future<void> addComment(CommentEntity comment) async {}

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    return [
      CommentEntity(
        id: 'c1',
        postId: postId,
        authorId: 'u2',
        authorName: 'Jane Smith',
        text: 'This is a mock comment to demonstrate comments working properly!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      CommentEntity(
        id: 'c2',
        postId: postId,
        authorId: 'u3',
        authorName: 'Alex Lee',
        text: 'Agreed, this is looking clean!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        parentId: 'c1',
      ),
    ];
  }

  @override
  Future<void> deleteComment(String postId, String commentId, String userId) async {}

  @override
  Future<void> toggleCommentLike(String postId, String commentId, String userId) async {}

  @override
  Future<Map<String, int>> getUserVotesForPosts(String userId, List<String> postIds) async {
    return {};
  }

  @override
  Future<String> uploadPostImage(String localPath, String fileName) async => '';

  @override
  Future<void> deletePost(String postId) async {}

  @override
  Future<Map<String, bool>> getUserLikedComments(String postId, String userId, List<String> commentIds) async {
    return {};
  }
}
