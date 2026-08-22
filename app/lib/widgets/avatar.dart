import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/models.dart';

/// Circular avatar rendered from the user's initials on a stable gradient.
///
/// Deliberately asset-free so the shell runs offline. Swap the [Container]
/// child for a `CachedNetworkImage` once real profile photos exist.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.user,
    this.size = 44,
    this.ringColor,
    this.ringWidth = 2,
  });

  final AppUser user;
  final double size;
  final Color? ringColor;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: user.avatarGradient,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: TextStyle(
          fontFamily: kFontFamily,
          fontFamilyFallback: kFontFallback,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (ringColor == null) return avatar;

    return Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor!, width: ringWidth),
      ),
      child: avatar,
    );
  }
}

/// Overlapping avatar row used on the home-screen room cards.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.users,
    this.size = 24,
    this.max = 5,
    this.overlap = 8,
  });

  final List<AppUser> users;
  final double size;
  final int max;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final shown = users.take(max).toList();
    final step = size - overlap;

    return SizedBox(
      width: shown.isEmpty ? 0 : size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceAlt, width: 1.5),
                ),
                child: AvatarCircle(user: shown[i], size: size),
              ),
            ),
        ],
      ),
    );
  }
}
