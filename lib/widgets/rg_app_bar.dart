import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../data/mock/rescue_grid_state.dart';

class RgAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showNotifications;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;

  const RgAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.showNotifications = true,
    this.onNotificationTap,
    this.actions,
    this.leading,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RescueGridState>();
    final canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      leading: leading ??
          (showBackButton && canPop
              ? IconButton(
                  icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: RgTypography.headingMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: RgTypography.caption.copyWith(
                color: RgColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        if (showNotifications)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.bell, size: 22),
                  onPressed: onNotificationTap ??
                      () {
                        // Open notification modal or view
                      },
                ),
                if (state.unreadNotificationCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: RgColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${state.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: RgColors.border,
          height: 1,
        ),
      ),
    );
  }
}
