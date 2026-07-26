import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onVideoCall;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onInfo;

  const ChatHeader({
    super.key,
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    this.imageUrl,
    this.onTap,
    this.onVideoCall,
    this.onVoiceCall,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final headerH = MediaQuery.of(context).size.height * 0.10;
    final avatarRadius = headerH * 0.3;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: headerH < 80 ? 80.0 : headerH,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _HeaderClipper(),
                  child: Container(
                    color: const Color(0xFF5A48E6),
                    padding: EdgeInsets.only(
                      left: screenW * 0.06,
                      right: screenW * 0.04,
                      top: headerH * 0.2,
                      bottom: headerH * 0.2,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: onTap,
                          child: SizedBox(
                            width: avatarRadius * 2,
                            height: avatarRadius * 2,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor:
                                      avatarColor.withValues(alpha: 0.25),
                                  backgroundImage:
                                      imageUrl != null && imageUrl!.isNotEmpty
                                          ? NetworkImage(imageUrl!)
                                          : null,
                                  child: imageUrl == null || imageUrl!.isEmpty
                                      ? Text(
                                          initials,
                                          style: TextStyle(
                                            fontSize: headerH * 0.22,
                                            fontWeight: FontWeight.w600,
                                            color: avatarColor,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      color:
                                          isOnline ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF5A48E6),
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: screenW * 0.03),
                        Expanded(
                          child: GestureDetector(
                            onTap: onTap,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: screenW * 0.04,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: headerH * 0.12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionCircle(
                          icon: Icons.videocam_outlined,
                          onTap: onVideoCall,
                        ),
                        SizedBox(width: screenW * 0.03),
                        _ActionCircle(
                          icon: Icons.phone_outlined,
                          onTap: onVoiceCall,
                        ),
                        SizedBox(width: screenW * 0.03),
                        _ActionCircle(
                          icon: Icons.info_outline,
                          onTap: onInfo,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCircle({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5A48E6),
          size: 24,
        ),
      ),
    );
  }
}
//               LONG               //

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    final scoopStart = w * 0.50;
    final scoopEnd = w * 0.68;
    final scoopDip = h * 0.92;

    path.moveTo(-w * 0.02, 0);
    path.lineTo(scoopStart, 0);
    path.cubicTo(
      scoopStart + (scoopEnd - scoopStart) * 0.25,
      0,
      scoopStart - (scoopEnd - scoopStart) * 0.05,
      scoopDip,
      scoopEnd,
      scoopDip,
    );
    path.lineTo(w * 0.82, scoopDip);
    path.cubicTo(
      w * 0.90,
      scoopDip,
      w,
      scoopDip + h * 0.06,
      w,
      h,
    );
    path.lineTo(0, h);
    path.lineTo(-w * 0.02, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

//               SHORT              //
/*
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    final scoopStart = w * 0.60;
    final scoopEnd = w * 0.78;
    final scoopDip = h * 0.90;

    path.moveTo(-w * 0.02, 0);
    path.lineTo(scoopStart, 0);
    path.cubicTo(
      scoopStart + (scoopEnd - scoopStart) * 0.18,
      scoopDip * 0.15,
      scoopStart + (scoopEnd - scoopStart) * 0.08,
      scoopDip * 0.60,
      scoopEnd,
      scoopDip,
    );
    path.cubicTo(
      w * 0.82,
      scoopDip,
      w * 0.88,
      scoopDip,
      w * 0.92,
      scoopDip + h * 0.03,
    );
    path.cubicTo(
      w * 0.96,
      scoopDip + h * 0.06,
      w,
      scoopDip + h * 0.08,
      w,
      h,
    );
    path.lineTo(0, h);
    path.lineTo(-w * 0.02, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
*/
/*
class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionCircle({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF5A48E6),
          size: 24,
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    final scoopStart = w * 0.50;
    final scoopEnd = w * 0.72;
    final scoopDip = h * 0.85;

    path.moveTo(-w * 0.02, 0);
    path.lineTo(scoopStart, 0);
    path.cubicTo(
      scoopStart + (scoopEnd - scoopStart) * 0.30,
      0,
      scoopStart + (scoopEnd - scoopStart) * 0.10,
      scoopDip * 0.72,
      scoopEnd,
      scoopDip,
    );
    path.cubicTo(
      w * 0.82,
      scoopDip,
      w * 0.88,
      scoopDip,
      w * 0.92,
      scoopDip + h * 0.03,
    );
    path.cubicTo(
      w * 0.96,
      scoopDip + h * 0.06,
      w,
      scoopDip + h * 0.08,
      w,
      h,
    );
    path.lineTo(0, h);
    path.lineTo(-w * 0.02, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
*/
