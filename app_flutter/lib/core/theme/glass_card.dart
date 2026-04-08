// lib/core/theme/glass_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 18,
    this.opacity = 0.78,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final disableEffects =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shape = borderRadius ?? BorderRadius.circular(AppTheme.radiusMedium);
    final fallbackBackground = isDark
        ? const Color(0xFF151B22).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: opacity);
    final effectiveBlur = disableEffects ? 0.0 : blur;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? fallbackBackground,
        borderRadius: shape,
        border: border ??
            Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.70),
            ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: isDark ? 0.02 : 0.36),
            Colors.white.withValues(alpha: isDark ? 0.00 : 0.12),
          ],
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: effectiveBlur <= 0
            ? content
            : BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: content,
              ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 22,
    this.opacity = 0.72,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius ?? BorderRadius.circular(AppTheme.radiusLarge),
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
