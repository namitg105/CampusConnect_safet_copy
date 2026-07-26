import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';

class CommunityFilesScreen extends StatelessWidget {
  const CommunityFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LightModeController lightModeController =
        Get.find<LightModeController>();

    return Obx(() {
      final isLightMode = lightModeController.isLightMode.value;

      final backgroundColor =
          isLightMode ? const Color(0xFFF4F1FC) : const Color(0xFF121214);
      final textColor = isLightMode ? const Color(0xFF1A1A1E) : Colors.white;
      final subTextColor =
          isLightMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
      final cardColor = isLightMode ? Colors.white : const Color(0xFF1E1E22);
      final dividerColor =
          isLightMode ? const Color(0xFFEEEEEE) : const Color(0xFF2D2D33);
      final brandColor = const Color(0xFF6139ED);

      return Scaffold(
        backgroundColor: backgroundColor,
        // Header
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: AppBar(
            backgroundColor: cardColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            shape: Border(bottom: BorderSide(color: dividerColor, width: 0.5)),
            title: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: textColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                // AI & ML Logo container
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/chat_assets/image 60.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 38,
                        height: 38,
                        color: brandColor,
                        child: const Center(
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'AI & ML Society',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '3.4K Members',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E676),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '243 Online',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Image.asset(
                  'assets/chat_assets/Notified bell.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.notifications_none, color: textColor);
                  },
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        body: Column(
          children: [
            // Tabs Sub-header Row
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubTab(Icons.home_outlined, 'Overview', false, subTextColor, brandColor),
                  _buildSubTab(Icons.calendar_today_outlined, 'Events', false, subTextColor, brandColor),
                  _buildSubTab(Icons.people_outline, 'Members', false, subTextColor, brandColor),
                  _buildSubTab(Icons.folder_open_outlined, 'Files', true, subTextColor, brandColor),
                ],
              ),
            ),
            // Divider below tabs
            Container(height: 1, color: dividerColor),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Files & Resources Title
                  Text(
                    'Files & Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search + Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isLightMode
                                  ? const Color(0xFFE4E0F3)
                                  : const Color(0xFF2D2D33),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: subTextColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(fontSize: 13, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'Search for files...',
                                    hintStyle: TextStyle(
                                      color: subTextColor.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLightMode
                                ? const Color(0xFFE4E0F3)
                                : const Color(0xFF2D2D33),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/chat_assets/filter icon 2.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.filter_alt_outlined, color: brandColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category Pills
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildCategoryPill('All files', true, brandColor, textColor),
                        _buildCategoryPill('documents', false, brandColor, textColor),
                        _buildCategoryPill('Presentations', false, brandColor, textColor),
                        _buildCategoryPill('code', false, brandColor, textColor),
                        _buildCategoryPill('others', false, brandColor, textColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Folders Grid Title
                  Text(
                    'Folder',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid of Folders (2 columns)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _buildFolderCard('Study Materials', '24 items', cardColor, textColor, subTextColor, brandColor),
                      _buildFolderCard('Lecture notes', '24 items', cardColor, textColor, subTextColor, brandColor),
                      _buildFolderCard('Assignments', '3 items', cardColor, textColor, subTextColor, brandColor),
                      _buildFolderCard('Projects', '90 items', cardColor, textColor, subTextColor, brandColor),
                      _buildFolderCard('Datasets', '24 items', cardColor, textColor, subTextColor, brandColor),
                      _buildFolderCard('Others', '12 items', cardColor, textColor, subTextColor, brandColor),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Files Title
                  Text(
                    'Recent Files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Recent Files list cards
                  _buildRecentFileCard(
                    fileName: 'Fine- tuning LLM’s- A complete guide.pdf',
                    fileSize: '2.7MB',
                    pdfAsset: 'assets/chat_assets/Simple Red.png',
                    cardBg: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildRecentFileCard(
                    fileName: 'DBMS notes',
                    fileSize: '2.7MB',
                    pdfAsset: 'assets/chat_assets/Simple Red_Orange_pdf.png',
                    cardBg: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildRecentFileCard(
                    fileName: 'Computerarchitecturecomplete.pdf',
                    fileSize: '2.7MB',
                    pdfAsset: 'assets/chat_assets/Simple Red_Blue_pdf.png',
                    cardBg: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildRecentFileCard(
                    fileName: 'Alrevised.ppt',
                    fileSize: '2.7MB',
                    pdfAsset: 'assets/chat_assets/Simple Red.png',
                    cardBg: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(top: BorderSide(color: dividerColor, width: 0.5)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', true, brandColor, subTextColor),
                _buildNavItem(Icons.people_outline, 'Communities', false, brandColor, subTextColor),
                // Floating center plus button style
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: brandColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: brandColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                _buildNavItem(Icons.chat_bubble_outline, 'Messages', false, brandColor, subTextColor),
                _buildNavItem(Icons.person_outline, 'Profile', false, brandColor, subTextColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubTab(
      IconData icon, String label, bool isSelected, Color subTextColor, Color brandColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? brandColor : subTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? brandColor : subTextColor,
              ),
            ),
          ],
        ),
        if (isSelected) ...[
          const SizedBox(height: 6),
          Container(
            width: 32,
            height: 2.5,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildCategoryPill(String label, bool isActive, Color brandColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? brandColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? brandColor : const Color(0xFFE4E0F3),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildFolderCard(
    String title,
    String itemCount,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color brandColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E0F3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Folder icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              'assets/chat_assets/Frame_folder.png',
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.folder, color: brandColor, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  itemCount,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert, size: 16, color: subTextColor),
        ],
      ),
    );
  }

  Widget _buildRecentFileCard({
    required String fileName,
    required String fileSize,
    required String pdfAsset,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E0F3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // PDF Thumbnail asset
          Image.asset(
            pdfAsset,
            width: 32,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 32,
              height: 38,
              color: Colors.red[50],
              child: const Center(
                child: Text(
                  'PDF',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  fileSize,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Download icon
          Image.asset(
            'assets/chat_assets/Frame_download.png',
            width: 18,
            height: 18,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.download, color: subTextColor, size: 18),
          ),
          const SizedBox(width: 12),
          Icon(Icons.more_vert, size: 16, color: subTextColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isSelected, Color brandColor, Color subTextColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? brandColor : subTextColor,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? brandColor : subTextColor,
          ),
        ),
      ],
    );
  }
}
