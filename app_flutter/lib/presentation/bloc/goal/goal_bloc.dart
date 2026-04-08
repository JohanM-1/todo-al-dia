// lib/presentation/bloc/goal/goal_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/repositories.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;

  GoalBloc({required this.goalRepository}) : super(const GoalState()) {
    on<LoadGoals>(_onLoadGoals);
    on<CreateGoal>(_onCreateGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<AddContribution>(_onAddContribution);
    on<MarkGoalCompleted>(_onMarkGoalCompleted);
    on<PauseGoal>(_onPauseGoal);
    on<ResumeGoal>(_onResumeGoal);
    on<AdjustGoalTarget>(_onAdjustGoalTarget);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();

      final goalsWithProgress = goals
          .map((goal) => GoalWithProgress(
                goal: goal,
                progress: goal.progress,
                estimatedDaysLeft: goal.estimatedDaysLeft,
              ))
          .toList();

      final totalSaved =
          goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
      final totalTarget =
          goals.fold<double>(0, (sum, g) => sum + g.targetAmount);

      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        goalsWithProgress: goalsWithProgress,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        totalSaved: totalSaved,
        totalTarget: totalTarget,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateGoal(CreateGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await goalRepository.createGoal(event.goal);
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();
      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        successMessage: 'Meta creada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateGoal(UpdateGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await goalRepository.updateGoal(event.goal);
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();
      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        successMessage: 'Meta actualizada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await goalRepository.deleteGoal(event.id);
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();
      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        successMessage: 'Meta eliminada exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddContribution(
      AddContribution event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await goalRepository.addContribution(
          event.goalId, event.amount, event.note);
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();

      final updatedGoal = goals.firstWhere((g) => g.id == event.goalId);
      String? successMessage = 'Contribución agregada exitosamente';
      if (updatedGoal.currentAmount >= updatedGoal.targetAmount &&
          !updatedGoal.isCompleted) {
        successMessage = '¡Felicidades! Has alcanzado tu meta de ahorro';
      }

      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        successMessage: successMessage,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onMarkGoalCompleted(
      MarkGoalCompleted event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goal = state.goals.firstWhere((g) => g.id == event.id);
      final updated = goal.copyWith(isCompleted: true);
      await goalRepository.updateGoal(updated);
      final goals = await goalRepository.getAllGoals();
      final active = goals.where((g) => !g.isCompleted && !g.isPaused).toList();
      final paused = goals.where((g) => !g.isCompleted && g.isPaused).toList();
      final completed = goals.where((g) => g.isCompleted).toList();
      emit(state.copyWith(
        isLoading: false,
        goals: goals,
        activeGoals: [...active, ...paused],
        completedGoals: completed,
        successMessage: 'Meta marcada como completada',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onPauseGoal(PauseGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goal = state.goals.firstWhere((g) => g.id == event.id);
      final updated = goal.copyWith(isPaused: true);
      await goalRepository.updateGoal(updated);
      add(LoadGoals());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onResumeGoal(ResumeGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goal = state.goals.firstWhere((g) => g.id == event.id);
      final updated = goal.copyWith(isPaused: false);
      await goalRepository.updateGoal(updated);
      add(LoadGoals());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAdjustGoalTarget(
      AdjustGoalTarget event, Emitter<GoalState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final goal = state.goals.firstWhere((g) => g.id == event.id);
      final updated = goal.copyWith(targetAmount: event.newTarget);
      await goalRepository.updateGoal(updated);
      add(LoadGoals());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
