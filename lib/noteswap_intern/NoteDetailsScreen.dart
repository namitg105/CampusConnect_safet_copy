import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noteswap/ViewModels/NotificationController.dart';
import 'package:noteswap/features/events/notifications/notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'note_data.dart';
import 'note_details_data.dart';
import 'AllReviewsScreen.dart';
import 'noteswap_controller.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  static const Color _background = Color(0xFFF7F6FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _accentDeep = Color(0xFF4F46E5);
  static const Color _textDark = Color(0xFF1F2747);
  static const Color _textMuted = Color(0xFF8B879E);
  static const Color _shadowColor = Color(0x0A000000);

  NoteDetail? _detail;
  bool _purchasing = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final detail =
          await Get.find<NoteswapController>().getDetail(widget.note);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detail = const NoteDetail(
          title: 'Note unavailable',
          subject: '',
          author: '',
          price: 'Free',
          rating: 0,
          ratingCount: 0,
          images: [],
          semester: '—',
          pages: '—',
          language: 'English',
          fileSize: '',
          downloads: 0,
          sellerName: '',
          sellerJoined: '',
          sellerNotes: 0,
          sellerAccent: Color(0xFF6366F1),
          reviews: [],
        );
      });
    }
  }

  Future<void> _buy() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to buy notes')),
      );
      return;
    }
    setState(() => _purchasing = true);
    try {
      await Get.find<NoteswapController>().purchase(widget.note);
      if (!mounted) return;
      // Reload so the detail reflects isPurchased (buyers list changed).
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note purchased successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not purchase note: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  /// Opens the purchased/owned file. Download counting is best-effort and
  /// never blocks opening the file.
  Future<void> _openFile() async {
    final detail = _detail;
    if (detail == null || detail.fileUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No download link for this note')),
      );
      return;
    }
    setState(() => _downloading = true);
    try {
      await Get.find<NoteswapController>().recordDownload(detail);
      final ok = await launchUrl(
        Uri.parse(detail.fileUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the note file')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the note file: $e')),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: detail == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _NavigationBar(),
                      const SizedBox(height: 24),
                      _ProductSection(
                        detail: detail,
                        purchasing: _purchasing,
                        downloading: _downloading,
                        onBuy: _buy,
                        onDownload: _openFile,
                      ),
                      const SizedBox(height: 28),
                      _SellerSection(detail: detail),
                      const SizedBox(height: 28),
                      _RatingsHeader(detail: detail),
                      const SizedBox(height: 16),
                      _RatingsSection(detail: detail),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _NoteDetailsScreenState._accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const _NotificationButton(),
              const SizedBox(width: 12),
              _CircleIconButton(
                icon: Icons.share_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Info of Share'),
                          const Text(
                            'Share will be implemented in upcoming events',
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    final notifCtrl = Get.find<NotificationController>();
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          _CircleIconButton(
            icon: Icons.notifications_none,
            onTap: () => Get.to(() => const NotificationsScreen()),
          ),
          if (notifCtrl.unreadCount.value > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: _NoteDetailsScreenState._shadowColor,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: _NoteDetailsScreenState._textDark,
          size: 22,
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final NoteDetail detail;
  final bool purchasing;
  final bool downloading;
  final VoidCallback onBuy;
  final VoidCallback onDownload;

  const _ProductSection({
    required this.detail,
    required this.purchasing,
    required this.downloading,
    required this.onBuy,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ImageGallery(images: detail.images),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _NoteDetailsScreenState._textDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _NoteDetailsScreenState._accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      detail.subject,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _NoteDetailsScreenState._accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                detail.price,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _NoteDetailsScreenState._accent,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${detail.rating}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _NoteDetailsScreenState._textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${detail.ratingCount} ratings)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: _NoteDetailsScreenState._textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _InfoTable(detail: detail),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final busy = purchasing || downloading;
                  final String label;
                  final VoidCallback? action;
                  final bool showDownloadIcon;
                  if (detail.isOwner) {
                    label = 'Your Note';
                    action = null;
                    showDownloadIcon = false;
                  } else if (detail.isPurchased) {
                    label = 'Download';
                    action = onDownload;
                    showDownloadIcon = true;
                  } else {
                    label = 'Buy Now';
                    action = onBuy;
                    showDownloadIcon = false;
                  }
                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: busy ? null : action,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: detail.isOwner
                              ? _NoteDetailsScreenState._textMuted.withOpacity(0.15)
                              : null,
                          gradient: detail.isOwner
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    _NoteDetailsScreenState._accent,
                                    _NoteDetailsScreenState._accentDeep,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (showDownloadIcon) ...[
                                      const Icon(
                                        Icons.download,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: detail.isOwner
                                            ? _NoteDetailsScreenState._textMuted
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;

  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: 140,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: _NoteDetailsScreenState._accent.withOpacity(0.1),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.menu_book,
          color: _NoteDetailsScreenState._accent,
          size: 28,
        ),
      );
    }
    return Column(
      children: [
        Container(
          width: 140,
          height: 180,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: _NoteDetailsScreenState._shadowColor,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.network(
            images.first,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _imageFallback(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 1; i < images.length; i++) ...[
              Container(
                width: 62,
                height: 62,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imageFallback(),
                ),
              ),
              if (i != images.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: _NoteDetailsScreenState._accent.withOpacity(0.1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        color: _NoteDetailsScreenState._accent,
        size: 28,
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  final NoteDetail detail;

  const _InfoTable({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(label: 'Subject', value: detail.subject),
        const SizedBox(height: 8),
        _InfoRow(label: 'Semester', value: detail.semester),
        const SizedBox(height: 8),
        _InfoRow(label: 'Pages', value: detail.pages),
        const SizedBox(height: 8),
        _InfoRow(label: 'Language', value: detail.language),
        const SizedBox(height: 8),
        _InfoRow(label: 'File Size', value: detail.fileSize),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _NoteDetailsScreenState._textMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _NoteDetailsScreenState._textDark,
          ),
        ),
      ],
    );
  }
}

class _SellerSection extends StatelessWidget {
  final NoteDetail detail;

  const _SellerSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seller Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _NoteDetailsScreenState._textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: detail.sellerAccent.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  detail.sellerName.isNotEmpty
                      ? detail.sellerName[0]
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: detail.sellerAccent,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.sellerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _NoteDetailsScreenState._textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${detail.sellerJoined} • ${detail.sellerNotes} notes shared',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _NoteDetailsScreenState._textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.verified,
                color: _NoteDetailsScreenState._accent,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingsHeader extends StatelessWidget {
  final NoteDetail detail;

  const _RatingsHeader({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Ratings & Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _NoteDetailsScreenState._textDark,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AllReviewsScreen(detail: detail),
              ),
            );
          },
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _NoteDetailsScreenState._accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingsSection extends StatelessWidget {
  final NoteDetail detail;

  const _RatingsSection({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RatingSummaryCard(detail: detail),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              for (var i = 0; i < detail.reviews.length; i++) ...[
                _ReviewCard(review: detail.reviews[i]),
                if (i != detail.reviews.length - 1)
                  const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  final NoteDetail detail;

  const _RatingSummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            detail.rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _NoteDetailsScreenState._textDark,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++) ...[
                  Icon(
                    i == 4 ? Icons.star_half : Icons.star,
                    color: const Color(0xFFF59E0B),
                    size: _starSize(context),
                  ),
                  if (i != 4) SizedBox(width: _starSize(context) * 0.12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${detail.ratingCount} ratings',
            style: const TextStyle(
              fontSize: 12,
              color: _NoteDetailsScreenState._textMuted,
            ),
          ),
        ],
      ),
    );
  }

  double _starSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth * 0.032).clamp(9.0, 18.0);
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _NoteDetailsScreenState._accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.name.isNotEmpty ? review.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _NoteDetailsScreenState._accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _NoteDetailsScreenState._textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: const Color(0xFFF59E0B),
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${review.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _NoteDetailsScreenState._textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          review.time,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _NoteDetailsScreenState._textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: _NoteDetailsScreenState._textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: _NoteDetailsScreenState._shadowColor,
        blurRadius: 20,
        spreadRadius: 0,
        offset: Offset(0, 5),
      ),
    ],
  );
}
