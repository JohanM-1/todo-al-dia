import 'dart:async';

// lib/presentation/pages/settings/category_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CategoryEntity> _expenseCategories = [];
  List<CategoryEntity> _incomeCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    unawaited(_loadCategories());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categoryRepo = context.read<CategoryRepository>();
      final expenses = await categoryRepo.getExpenseCategories();
      final incomes = await categoryRepo.getIncomeCategories();

      if (mounted) {
        setState(() {
          _expenseCategories = expenses;
          _incomeCategories = incomes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final horizontalPadding = isWide ? 24.0 : 16.0;
        final maxContentWidth = isWide ? 800.0 : double.infinity;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Categorías'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Gastos'),
                Tab(text: 'Ingresos'),
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryList(_expenseCategories, isExpense: true),
                    _buildCategoryList(_incomeCategories, isExpense: false),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCategoryDialog(
              context,
              isExpense: _tabController.index == 0,
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCategoryList(List<CategoryEntity> categories,
      {required bool isExpense}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpense ? Icons.shopping_cart : Icons.attach_money,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay categorías',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Toca + para crear una nueva',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final systemCategories = categories.where((c) => c.isSystem).toList();
    final customCategories = categories.where((c) => !c.isSystem).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (systemCategories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Predeterminadas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...systemCategories
              .map((c) => _buildCategoryTile(c, isExpense: isExpense)),
          const SizedBox(height: 16),
        ],
        if (customCategories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Personalizadas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...customCategories.map((c) =>
              _buildCategoryTile(c, canEdit: true, isExpense: isExpense)),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sin categorías personalizadas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryTile(CategoryEntity category,
      {bool canEdit = false, required bool isExpense}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(category.colorIndex),
          child: Text(
            category.icon,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(category.name),
        subtitle: category.isSystem
            ? Text(
                'Predeterminada',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: canEdit
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    unawaited(_showCategoryDialog(context,
                        category: category, isExpense: isExpense));
                  } else if (value == 'delete') {
                    unawaited(_deleteCategory(category));
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.red.shade100,
      Colors.teal.shade100,
      Colors.pink.shade100,
      Colors.indigo.shade100,
      Colors.amber.shade100,
      Colors.cyan.shade100,
    ];
    return colors[index % colors.length];
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    CategoryEntity? category,
    required bool isExpense,
  }) async {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    String selectedIcon = category?.icon ?? '📁';
    int selectedColorIndex = category?.colorIndex ?? 0;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar categoría' : 'Nueva categoría'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ícono',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _iconOptions.map((icon) {
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() => selectedIcon = icon);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(icon,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(10, (index) {
                        final isSelected = index == selectedColorIndex;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() => selectedColorIndex = index);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(index),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El nombre es requerido')),
                      );
                      return;
                    }

                    try {
                      final categoryRepo = context.read<CategoryRepository>();

                      if (isEditing) {
                        await categoryRepo.updateCategory(
                          category.copyWith(
                            name: name,
                            icon: selectedIcon,
                            colorIndex: selectedColorIndex,
                          ),
                        );
                      } else {
                        await categoryRepo.createCategory(
                          CategoryEntity(
                            name: name,
                            icon: selectedIcon,
                            colorIndex: selectedColorIndex,
                            isIncome: !isExpense,
                          ),
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadCategories(); // ignore: unawaited_futures
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(CategoryEntity category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${category.name}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) {
        return;
      }

      try {
        // Note: The repository doesn't have a delete method
        // For now, we just show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('La eliminación de categorías aún no está implementada'),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  static const List<String> _iconOptions = [
    '🍔',
    '🚗',
    '🏠',
    '🎬',
    '🛒',
    '💊',
    '👕',
    '📱',
    '🎁',
    '📦',
    '💰',
    '💵',
    '📈',
    '🎁',
    '💎',
    '➕',
    '🏋️',
    '📚',
    '🎮',
    '✈️',
    '☕',
    '🍺',
    '🎵',
    '📷',
    '💼',
    '🏥',
    '🎓',
    '🐕',
    '🌱',
    '⚽',
  ];
}
