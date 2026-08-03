import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 5.0, // Reduced default blur for better performance
    this.opacity = 0.1,
    this.borderRadius = 16.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Optimization: Don't use BackdropFilter if blur is 0
    if (blur == 0) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: child,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white.withOpacity(0.7),
          elevation: 0,
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
