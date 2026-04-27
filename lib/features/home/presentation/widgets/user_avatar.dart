import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medinear_app/core/localization/translate_helper.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final UserEntity? user;
  final double radius;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = user?.imageUrl != null && user!.imageUrl!.isNotEmpty;

    if (hasImage) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(user!.imageUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        (user?.name?.isNotEmpty == true)
            ? user!.name.substring(0, 1).toUpperCase()
            : context.tr("default_user_letter"),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
