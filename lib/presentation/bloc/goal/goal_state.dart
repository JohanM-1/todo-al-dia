// lib/presentation/bloc/goal/goal_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class GoalWithProgress extends Equatable {
  final GoalEntity goal;
  final double progress;
  final int? estimatedDaysLeft;
  final CategoryEntity? category;

  const GoalWithProgress({
    required this.goal,
    required this.progress,
    this.estimatedDaysLeft,
    this.category,
  });

  @override
  List<Object?> get props => [goal, progress, estimatedDaysLeft, category];
}

class GoalState extends Equatable {
  final bool isLoading;
  final List<GoalEntity> goals;
  final List<GoalWithProgress> goalsWithProgress;
  final List<GoalEntity> activeGoals;
  final List<GoalEntity> completedGoals;
  final double totalSaved;
  final double totalTarget;
  final String? error;
  final String? successMessage;

  const GoalState({
    this.isLoading = false,
    this.goals = const [],
    this.goalsWithProgress = const [],
    this.activeGoals = const [],
    this.completedGoals = const [],
    this.totalSaved = 0,
    this.totalTarget = 0,
    this.error,
    this.successMessage,
  });

  GoalState copyWith({
    bool? isLoading,
    List<GoalEntity>? goals,
    List<GoalWithProgress>? goalsWithProgress,
    List<GoalEntity>? activeGoals,
    List<GoalEntity>? completedGoals,
    double? totalSaved,
    double? totalTarget,
    String? error,
    String? successMessage,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      goalsWithProgress: goalsWithProgress ?? this.goalsWithProgress,
      activeGoals: activeGoals ?? this.activeGoals,
      completedGoals: completedGoals ?? this.completedGoals,
      totalSaved: totalSaved ?? this.totalSaved,
      totalTarget: totalTarget ?? this.totalTarget,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        goals,
        goalsWithProgress,
        activeGoals,
        completedGoals,
        totalSaved,
        totalTarget,
        error,
        successMessage
      ];
}
