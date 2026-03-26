// lib/presentation/bloc/movement/movement_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/repositories/repositories.dart';
import 'movement_event.dart';
import 'movement_state.dart';

class MovementBloc extends Bloc<MovementEvent, MovementState> {
  final MovementRepository movementRepository;
  final CategoryRepository categoryRepository;

  MovementBloc({
    required this.movementRepository,
    required this.categoryRepository,
  }) : super(const MovementState()) {
    on<LoadMovements>(_onLoadMovements);
    on<LoadMovementsByDateRange>(_onLoadMovementsByDateRange);
    on<LoadMovementsByCategory>(_onLoadMovementsByCategory);
    on<CreateMovement>(_onCreateMovement);
    on<UpdateMovement>(_onUpdateMovement);
    on<DeleteMovement>(_onDeleteMovement);
    on<FilterMovements>(_onFilterMovements);
    on<ClearMovementFilter>(_onClearMovementFilter);
  }

  Future<void> _onLoadMovements(
      LoadMovements event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final movements = await movementRepository.getAllMovements();
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements: movements,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMovementsByDateRange(
      LoadMovementsByDateRange event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final movements = await movementRepository.getMovementsByDateRange(
          event.start, event.end);
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements: movements,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMovementsByCategory(
      LoadMovementsByCategory event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final movements =
          await movementRepository.getMovementsByCategory(event.categoryId);
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements: movements,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateMovement(
      CreateMovement event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await movementRepository.createMovement(event.movement);
      final movements = await movementRepository.getAllMovements();
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements:
            state.hasFilter ? _applyFilters(movements) : movements,
        successMessage: 'Movimiento creado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateMovement(
      UpdateMovement event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await movementRepository.updateMovement(event.movement);
      final movements = await movementRepository.getAllMovements();
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements:
            state.hasFilter ? _applyFilters(movements) : movements,
        successMessage: 'Movimiento actualizado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDeleteMovement(
      DeleteMovement event, Emitter<MovementState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await movementRepository.deleteMovement(event.id);
      final movements = await movementRepository.getAllMovements();
      emit(state.copyWith(
        isLoading: false,
        movements: movements,
        filteredMovements:
            state.hasFilter ? _applyFilters(movements) : movements,
        successMessage: 'Movimiento eliminado exitosamente',
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onFilterMovements(FilterMovements event, Emitter<MovementState> emit) {
    final filtered = _applyFilters(state.movements, event.categoryId,
        event.type, event.startDate, event.endDate);
    emit(state.copyWith(
      filteredMovements: filtered,
      filterCategoryId: event.categoryId,
      filterType: event.type,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
  }

  void _onClearMovementFilter(
      ClearMovementFilter event, Emitter<MovementState> emit) {
    emit(state.copyWith(
      filteredMovements: state.movements,
      clearCategoryFilter: true,
      clearTypeFilter: true,
      clearStartDateFilter: true,
      clearEndDateFilter: true,
    ));
  }

  List<MovementEntity> _applyFilters(
    List<MovementEntity> movements, [
    int? categoryId,
    MovementType? type,
    DateTime? startDate,
    DateTime? endDate,
  ]) {
    return movements.where((m) {
      if (categoryId != null && m.categoryId != categoryId) return false;
      if (type != null && m.type != type) return false;
      if (startDate != null && m.date.isBefore(startDate)) return false;
      if (endDate != null && m.date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }
}
