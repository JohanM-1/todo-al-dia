// lib/presentation/pages/goals/goals_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/entities.dart';
import '../../bloc/goal/goal_bloc.dart';
import '../../bloc/goal/goal_event.dart';
import '../../bloc/goal/goal_state.dart';
import '../../widgets/currency_text_field.dart';
import '../../widgets/goal_progress_widget.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<GoalBloc>().add(LoadGoals());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final horizontalPadding = isWide ? 24.0 : 16.0;
        final maxContentWidth =
            isWide ? 1000.0 : (isTablet ? 600.0 : double.infinity);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Metas de Ahorro'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Activas'),
                Tab(text: 'Completadas'),
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 8),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: BlocConsumer<GoalBloc, GoalState>(
                  listener: (context, state) {
                    if (state.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${state.error}')),
                      );
                    }
                    if (state.successMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.successMessage!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.isLoading && state.goals.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _GoalsList(
                          goals: state.activeGoals,
                          emptyMessage: 'No hay metas activas',
                          emptySubtitle:
                              'Toca + para crear tu primera meta de ahorro',
                          isActive: true,
                          onDelete: _deleteGoal,
                          onAddContribution: _showContributionDialog,
                          onMarkCompleted: _markCompleted,
                          onPause: _pauseGoal,
                          onResume: _resumeGoal,
                        ),
                        _GoalsList(
                          goals: state.completedGoals,
                          emptyMessage: 'No hay metas completadas',
                          emptySubtitle: 'Completa una meta para verla aquí',
                          isActive: false,
                          onDelete: _deleteGoal,
                          onAddContribution: _showContributionDialog,
                          onMarkCompleted: _markCompleted,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.push('/goal/add');
              if (context.mounted) {
                context.read<GoalBloc>().add(LoadGoals());
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _showContributionDialog(GoalEntity goal) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar a "${goal.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Meta: ${CurrencyFormatter.formatWithSymbol(goal.targetAmount, AppDatabase.currentCurrency)}\n'
              'Actual: ${CurrencyFormatter.formatWithSymbol(goal.currentAmount, AppDatabase.currentCurrency)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            CurrencyTextField(
              controller: amountController,
              currencyCode: AppDatabase.currentCurrency,
              labelText: 'Monto',
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = CurrencyFormatter.parse(
                amountController.text,
                AppDatabase.currentCurrency,
              );
              if (parsed != null && parsed > 0) {
                Navigator.pop(context, parsed);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (amount != null && mounted) {
      context.read<GoalBloc>().add(AddContribution(
            goalId: goal.id!,
            amount: amount,
            note: noteController.text.isEmpty ? null : noteController.text,
          ));
    }

    amountController.dispose();
    noteController.dispose();
  }

  Future<void> _deleteGoal(GoalEntity goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Meta'),
        content: Text(
            '¿Estás seguro de que deseas eliminar la meta "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && goal.id != null) {
      if (!mounted) {
        return;
      }

      context.read<GoalBloc>().add(DeleteGoal(id: goal.id!));
    }
  }

  Future<void> _markCompleted(GoalEntity goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Completada'),
        content: Text('¿Marcar la meta "${goal.name}" como completada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );

    if (confirmed == true && goal.id != null) {
      if (!mounted) {
        return;
      }

      context.read<GoalBloc>().add(MarkGoalCompleted(id: goal.id!));
    }
  }

  void _pauseGoal(GoalEntity goal) {
    if (goal.id != null) {
      context.read<GoalBloc>().add(PauseGoal(id: goal.id!));
    }
  }

  void _resumeGoal(GoalEntity goal) {
    if (goal.id != null) {
      context.read<GoalBloc>().add(ResumeGoal(id: goal.id!));
    }
  }
}

class _GoalsList extends StatelessWidget {
  final List<GoalEntity> goals;
  final String emptyMessage;
  final String emptySubtitle;
  final bool isActive;
  final void Function(GoalEntity) onDelete;
  final void Function(GoalEntity) onAddContribution;
  final void Function(GoalEntity) onMarkCompleted;
  final void Function(GoalEntity)? onPause;
  final void Function(GoalEntity)? onResume;

  const _GoalsList({
    required this.goals,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.isActive,
    required this.onDelete,
    required this.onAddContribution,
    required this.onMarkCompleted,
    this.onPause,
    this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.savings_outlined : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GoalBloc>().add(LoadGoals());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return _GoalCard(
            goal: goal,
            isActive: isActive,
            onDelete: () => onDelete(goal),
            onAddContribution: () => onAddContribution(goal),
            onMarkCompleted: () => onMarkCompleted(goal),
            onTap: () => context.push('/goal/edit/${goal.id}'),
            onPause: goal.isPaused
                ? null
                : (onPause != null ? () => onPause!(goal) : null),
            onResume: goal.isPaused && onResume != null
                ? () => onResume!(goal)
                : null,
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final bool isActive;
  final VoidCallback onDelete;
  final VoidCallback onAddContribution;
  final VoidCallback onMarkCompleted;
  final VoidCallback onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  const _GoalCard({
    required this.goal,
    required this.isActive,
    required this.onDelete,
    required this.onAddContribution,
    required this.onMarkCompleted,
    required this.onTap,
    this.onPause,
    this.onResume,
  });

  String get _goalTypeLabel {
    switch (goal.goalType) {
      case GoalType.savings:
        return 'Ahorro';
      case GoalType.expenseControl:
        return 'Control de Gasto';
      case GoalType.event:
        return 'Evento';
    }
  }

  IconData get _goalTypeIcon {
    switch (goal.goalType) {
      case GoalType.savings:
        return Icons.savings;
      case GoalType.expenseControl:
        return Icons.control_camera;
      case GoalType.event:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final remaining =
        (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final daysLeft = goal.targetDate?.difference(DateTime.now()).inDays;
    final estimatedDaysLeft = goal.estimatedDaysLeft;

    return Hero(
      tag: 'goal-${goal.id}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Goal type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _goalTypeIcon,
                            size: 14,
                            color: AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _goalTypeLabel,
                            style: const TextStyle(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Paused indicator
                    if (goal.isPaused)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pause_circle,
                              size: 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pausada',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (goal.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.budgetSuccessColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppTheme.budgetSuccessColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Completada',
                              style: TextStyle(
                                color: AppTheme.budgetSuccessColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  goal.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GoalProgressWidget(
                  currentAmount: goal.currentAmount,
                  targetAmount: goal.targetAmount,
                  size: 80,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CurrencyFormatter.formatWithSymbol(
                              goal.currentAmount, AppDatabase.currentCurrency),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.budgetSuccessColor,
                          ),
                        ),
                        Text(
                          'de ${CurrencyFormatter.formatWithSymbol(goal.targetAmount, AppDatabase.currentCurrency)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatWithSymbol(
                              remaining, AppDatabase.currentCurrency),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'falta',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Estimated time
                if (goal.targetDate != null &&
                    !goal.isCompleted &&
                    !goal.isPaused) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: daysLeft != null && daysLeft < 7
                            ? AppTheme.budgetCriticalColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysLeft != null && daysLeft > 0
                            ? '$daysLeft días restantes'
                            : 'Fecha límite vencida',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: daysLeft != null && daysLeft < 7
                              ? AppTheme.budgetCriticalColor
                              : Colors.grey,
                        ),
                      ),
                      if (estimatedDaysLeft != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(~${estimatedDaysLeft}d estimado)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (isActive) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAddContribution,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!goal.isCompleted &&
                          goal.goalType == GoalType.savings) ...[
                        IconButton(
                          onPressed: goal.isPaused ? onResume : onPause,
                          icon: Icon(
                              goal.isPaused ? Icons.play_arrow : Icons.pause),
                          tooltip: goal.isPaused ? 'Reanudar' : 'Pausar',
                          color: Colors.orange,
                        ),
                      ],
                      if (!goal.isCompleted)
                        IconButton(
                          onPressed: onMarkCompleted,
                          icon: const Icon(Icons.check),
                          tooltip: 'Marcar como completada',
                          color: AppTheme.budgetSuccessColor,
                        ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Eliminar',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
