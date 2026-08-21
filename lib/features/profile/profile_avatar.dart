import 'package:flutter/material.dart';

import '../../domain/profile_content.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.avatarId,
    required this.frameId,
    super.key,
    this.size = 160,
  });

  final String avatarId;
  final String frameId;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.all(size * 0.11),
          child: ClipOval(
            child: Image.asset(
              profileAvatarById(avatarId).asset,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Image.asset(profileFrameById(frameId).asset, fit: BoxFit.contain),
      ],
    ),
  );
}
