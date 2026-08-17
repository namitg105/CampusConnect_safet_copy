import 'package:flutter/material.dart';

import 'note_details_data.dart';

class AllReviewsScreen extends StatelessWidget {
  final NoteDetail detail;

  const AllReviewsScreen({super.key, required this.detail});

  static const Color _background = Color(0xFFF7F6FC);
  static const Color _accent = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF1F2747);
  static const Color _textMuted = Color(0xFF8B879E);
  static const Color _shadowColor = Color(0x0A000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      extendBody: false,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(title: detail.title),
                const SizedBox(height: 24),
                _RatingSummary(detail: detail),
                const SizedBox(height: 24),
                const Text(
                  'All Reviews',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < detail.reviews.length; i++) ...[
                  _ReviewCard(review: detail.reviews[i]),
                  if (i != detail.reviews.length - 1)
                    const SizedBox(height: 14),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: AllReviewsScreen._shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back,
                color: AllReviewsScreen._textDark,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AllReviewsScreen._textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final NoteDetail detail;

  const _RatingSummary({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AllReviewsScreen._textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${detail.ratingCount} ratings',
                style: const TextStyle(
                  fontSize: 12,
                  color: AllReviewsScreen._textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    Icon(
                      i == 4 ? Icons.star_half : Icons.star,
                      color: const Color(0xFFF59E0B),
                      size: 20,
                    ),
                    if (i != 4) const SizedBox(width: 3),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AllReviewsScreen._accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.name.isNotEmpty ? review.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AllReviewsScreen._accent,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AllReviewsScreen._textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: const Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${review.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AllReviewsScreen._textMuted,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          review.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AllReviewsScreen._textMuted,
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
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AllReviewsScreen._textMuted,
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
        color: AllReviewsScreen._shadowColor,
        blurRadius: 20,
        spreadRadius: 0,
        offset: Offset(0, 5),
      ),
    ],
  );
}
