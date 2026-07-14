# Technical Presentation: CampusConnect (uniConnect)

## 1. Clean Architecture (3-Layered Approach)
- **Presentation**: BLoC handles authentication state updates. GetX manages light/dark mode UI rendering, scrolling feed lists, comments, and dynamic tag list states.
- **Domain**: Decoupled use-cases (`GetFeedUseCase`, `AddCommentUseCase`, `GetProfileUseCase`) and entities (`PostEntity`, `CommentEntity`) mapping business rules.
- **Data**: Data access implementation via `PostRepoImpl` and `FirebaseAuthRepo` interfacing with Cloud Firestore and Firebase Storage.

## 2. Dynamic Features & Refinements
- **Real-Time Recent Discussions**: Displays the top 3 newest discussions dynamically queried from Firestore based on the user's college domain.
- **Robust Image Attachments**: Attached post pictures display with lazy-loading progress circles, custom fit aspect scaling, and offline network-error builders.
- **Verify All & Access Routing**: Bound quick access items and 'View all' action buttons to route smoothly to the post feed (`CampusFeedScreen`).
- **Profile settings Screen**: Converts Figma mockup to code. Loads initials, display name, and email from Firestore database collections.
- **Race Condition Resolution**: Wrapped Dashboard One with a `BlocListener` to load profile databases reactively upon successful login.

## 3. Security & Rules
- Restricted Firestore reads and writes to authenticated students matching the author's college domain (`firestore.rules`).
- Custom comment upvote permissions implemented and verified using automated test assertions (`posts_feature_test.dart`).
