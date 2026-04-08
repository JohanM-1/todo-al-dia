// lib/presentation/bloc/movement/movement_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

abstract class MovementEvent extends Equatable {
  const MovementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovements extends MovementEvent {}

class LoadMovementsByDateRange extends MovementEvent {
  final DateTime start;
  final DateTime end;

  const LoadMovementsByDateRange({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class LoadMovementsByCategory extends MovementEvent {
  final int categoryId;

  const LoadMovementsByCategory({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class CreateMovement extends MovementEvent {
  final MovementEntity movement;

  const CreateMovement({required this.movement});

  @override
  List<Object?> get props => [movement];
}

class UpdateMovement extends MovementEvent {
  final MovementEntity movement;

  const UpdateMovement({required this.movement});

  @override
  List<Object?> get props => [movement];
}

class DeleteMovement extends MovementEvent {
  final int id;

  const DeleteMovement({required this.id});

  @override
  List<Object?> get props => [id];
}

class FilterMovements extends MovementEvent {
  final int? categoryId;
  final MovementType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterMovements({
    this.categoryId,
    this.type,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [categoryId, type, startDate, endDate];
}

class ClearMovementFilter extends MovementEvent {}
