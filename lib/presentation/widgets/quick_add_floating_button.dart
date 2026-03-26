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
    if (isExtended) {
      return FloatingActionButton.extended(
        key: const ValueKey('home_fab'),
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      );
    }

    return FloatingActionButton(
      key: const ValueKey('home_fab'),
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
