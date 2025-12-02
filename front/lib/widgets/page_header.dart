import 'package:flutter/material.dart';
import '../theme/typography.dart';

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PageHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
    );
  }
}
