// lib/presentation/widgets/quick_add_floating_button.dart
import 'package:flutter/material.dart';

class QuickAddFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isExtended;
  final String label;
  final IconData icon;

  const QuickAddFloatingButton({
    super.key,
    required this.onPressed,
    this.isExtended = true,
    this.label = 'Agregar movimiento',
    this.icon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(isExtended ? 20 : 18),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    );

    if (isExtended) {
      return DecoratedBox(
        decoration: decoration,
        child: FloatingActionButton.extended(
          key: const ValueKey('home_fab'),
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: FloatingActionButton(
        key: const ValueKey('home_fab'),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
