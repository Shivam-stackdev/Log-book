import 'package:flutter/material.dart';

/// Optimized glass container without expensive BackdropFilter
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Optimized AppBar without BackdropFilter for better performance
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white.withOpacity(0.85),
      elevation: 1,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.white.withOpacity(0.5),
      shadowColor: Colors.black.withOpacity(0.08),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
