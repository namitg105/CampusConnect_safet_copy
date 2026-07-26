import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/DarkModeViewModels.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaLinksDocsPage extends StatefulWidget {
  final String groupId;
  const MediaLinksDocsPage({super.key, required this.groupId});

  @override
  State<MediaLinksDocsPage> createState() => _MediaLinksDocsPageState();
}

class _MediaLinksDocsPageState extends State<MediaLinksDocsPage> {
  String _selectedCategory = 'All files';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  Stream<QuerySnapshot> _streamForTypes(List<String> types) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .where('type', whereIn: types)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      const brandColor = Color(0xFF6139ED);

      return Scaffold(
        backgroundColor: backgroundColor,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Section Title
            Text(
              'Files & Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar & Filter Button
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
                            controller: _searchController,
                            style: TextStyle(fontSize: 13, color: textColor),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.toLowerCase().trim();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search for files or links...',
                              hintStyle: TextStyle(
                                color: subTextColor.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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

            // Category Filter Pills
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryPill('All files', brandColor, textColor),
                  _buildCategoryPill('documents', brandColor, textColor),
                  _buildCategoryPill('media', brandColor, textColor),
                  _buildCategoryPill('links', brandColor, textColor),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Folders Section
            Text(
              'Folders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _streamForTypes(
                  ['file', 'doc', 'document', 'image', 'video', 'link']),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                int docCount = 0;
                int mediaCount = 0;
                int linkCount = 0;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? '';
                  if (['file', 'doc', 'document'].contains(type)) docCount++;
                  if (['image', 'video'].contains(type)) mediaCount++;
                  if (type == 'link') linkCount++;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildFolderCard('Documents', '$docCount items', cardColor,
                        textColor, subTextColor, brandColor),
                    _buildFolderCard('Media', '$mediaCount items', cardColor,
                        textColor, subTextColor, brandColor),
                    _buildFolderCard('Shared Links', '$linkCount items',
                        cardColor, textColor, subTextColor, brandColor),
                    _buildFolderCard('Others', '${docs.length} total',
                        cardColor, textColor, subTextColor, brandColor),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Content List Header
            Text(
              'Recent Shared Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),

            // Firestore Data Renderer
            _buildItemsList(
                cardColor, textColor, subTextColor, brandColor, isLightMode),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryPill(String label, Color brandColor, Color textColor) {
    final isActive = _selectedCategory.toLowerCase() == label.toLowerCase();
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
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
            label[0].toUpperCase() + label.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : textColor,
            ),
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

  Widget _buildItemsList(Color cardBg, Color textColor, Color subTextColor,
      Color brandColor, bool isLightMode) {
    List<String> types = [];
    switch (_selectedCategory.toLowerCase()) {
      case 'documents':
        types = ['file', 'doc', 'document'];
        break;
      case 'media':
        types = ['image', 'video'];
        break;
      case 'links':
        types = ['link'];
        break;
      default:
        types = ['file', 'doc', 'document', 'image', 'video', 'link'];
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _streamForTypes(types),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: brandColor));
        }

        var docs = snapshot.data?.docs ?? [];

        // Apply local search filtering
        if (_searchQuery.isNotEmpty) {
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['fileName'] ??
                    data['name'] ??
                    data['text'] ??
                    data['link'] ??
                    '')
                .toString()
                .toLowerCase();
            return name.contains(_searchQuery);
          }).toList();
        }

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No items found.',
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final type = (data['type'] ?? '').toString();
            final url = (data['mediaUrl'] ??
                    data['fileUrl'] ??
                    data['url'] ??
                    data['link'] ??
                    data['text'] ??
                    '')
                .toString();
            final fileName =
                (data['fileName'] ?? data['name'] ?? 'Shared File').toString();

            if (type == 'link') {
              final Uri? parsedUri = Uri.tryParse(url);
              final String domain = parsedUri?.host.isNotEmpty == true
                  ? parsedUri!.host
                  : 'Web Link';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFE4E0F3), width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.language, color: brandColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            domain,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10, color: subTextColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_rounded,
                          size: 16, color: subTextColor),
                      onPressed: () => _copyToClipboard(url, 'Link copied!'),
                    ),
                    IconButton(
                      icon: Icon(Icons.open_in_new_rounded,
                          size: 16, color: brandColor),
                      onPressed: () => _openUrl(url),
                    ),
                  ],
                ),
              );
            }

            // File or Media render format
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4E0F3), width: 0.5),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/chat_assets/Simple Red.png',
                    width: 32,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      type == 'image' ? Icons.image : Icons.insert_drive_file,
                      color: brandColor,
                      size: 28,
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
                              color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['size'] != null
                              ? data['size'].toString()
                              : 'File item',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: url.isNotEmpty ? () => _openUrl(url) : null,
                    child: Image.asset(
                      'assets/chat_assets/Frame_download.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.download, color: subTextColor, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.more_vert, size: 16, color: subTextColor),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
