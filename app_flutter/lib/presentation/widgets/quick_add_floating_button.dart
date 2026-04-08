// lib/presentation/widgets/quick_add_floating_button.dart
import 'package:flutter/material.dart';

class QuickAddFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isExtended;

  const QuickAddFloatingButton({
    super.key,
    required this.onPressed,
    this.isExtended = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(isExtended ? 20 : 18),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
          blurRadius: 24,
          offset: const Offset(0, 14),
        ),
      ],
    );

    if (isExtended) {
      return DecoratedBox(
        decoration: decoration,
        child: FloatingActionButton.extended(
          key: const ValueKey('home_fab'),
          onPressed: onPressed,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar movimiento'),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: FloatingActionButton(
        key: const ValueKey('home_fab'),
        onPressed: onPressed,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
