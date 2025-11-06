import 'package:flutter/material.dart';
import '../theme/typography.dart';

class ModalSheet extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const ModalSheet({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModalHandle(),
          const SizedBox(height: 24),
          child,
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildModalHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class ModalOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final bool showArrow;

  const ModalOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final optionColor = color ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: optionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: optionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: optionColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                color: optionColor.withOpacity(0.5),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionOption extends StatelessWidget {
  final String roleName;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionOption({
    super.key,
    required this.roleName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFFF312E) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF312E).withOpacity(0.15)
              : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF312E) : Colors.grey[800]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                roleName,
                style: AppTypography.bodyLarge.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFFF312E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? userName;
  final double size;

  const UserAvatar({
    super.key,
    this.userName,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(
              color: const Color(0xFFFF312E),
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              size: 40,
              color: Color(0xFFFF312E),
            ),
          ),
        ),
        if (userName != null) ...[
          const SizedBox(height: 12),
          Text(
            userName!,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
