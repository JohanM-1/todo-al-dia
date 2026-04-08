// lib/presentation/bloc/goal/goal_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class CreateGoal extends GoalEvent {
  final GoalEntity goal;

  const CreateGoal({required this.goal});

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final GoalEntity goal;

  const UpdateGoal({required this.goal});

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final int id;

  const DeleteGoal({required this.id});

  @override
  List<Object?> get props => [id];
}

class AddContribution extends GoalEvent {
  final int goalId;
  final double amount;
  final String? note;

  const AddContribution(
      {required this.goalId, required this.amount, this.note});

  @override
  List<Object?> get props => [goalId, amount, note];
}

class MarkGoalCompleted extends GoalEvent {
  final int id;

  const MarkGoalCompleted({required this.id});

  @override
  List<Object?> get props => [id];
}

class PauseGoal extends GoalEvent {
  final int id;

  const PauseGoal({required this.id});

  @override
  List<Object?> get props => [id];
}

class ResumeGoal extends GoalEvent {
  final int id;

  const ResumeGoal({required this.id});

  @override
  List<Object?> get props => [id];
}

class AdjustGoalTarget extends GoalEvent {
  final int id;
  final double newTarget;

  const AdjustGoalTarget({required this.id, required this.newTarget});

  @override
  List<Object?> get props => [id, newTarget];
}
