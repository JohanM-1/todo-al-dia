// lib/presentation/bloc/movement/movement_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entities.dart';

class MovementState extends Equatable {
  final bool isLoading;
  final List<MovementEntity> movements;
  final List<MovementEntity> filteredMovements;
  final int? filterCategoryId;
  final MovementType? filterType;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? error;
  final String? successMessage;

  const MovementState({
    this.isLoading = false,
    this.movements = const [],
    this.filteredMovements = const [],
    this.filterCategoryId,
    this.filterType,
    this.filterStartDate,
    this.filterEndDate,
    this.error,
    this.successMessage,
  });

  bool get hasFilter =>
      filterCategoryId != null ||
      filterType != null ||
      filterStartDate != null ||
      filterEndDate != null;

  MovementState copyWith({
    bool? isLoading,
    List<MovementEntity>? movements,
    List<MovementEntity>? filteredMovements,
    int? filterCategoryId,
    MovementType? filterType,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? error,
    String? successMessage,
    bool clearCategoryFilter = false,
    bool clearTypeFilter = false,
    bool clearStartDateFilter = false,
    bool clearEndDateFilter = false,
  }) {
    return MovementState(
      isLoading: isLoading ?? this.isLoading,
      movements: movements ?? this.movements,
      filteredMovements: filteredMovements ?? this.filteredMovements,
      filterCategoryId: clearCategoryFilter
          ? null
          : (filterCategoryId ?? this.filterCategoryId),
      filterType: clearTypeFilter ? null : (filterType ?? this.filterType),
      filterStartDate: clearStartDateFilter
          ? null
          : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearEndDateFilter ? null : (filterEndDate ?? this.filterEndDate),
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        movements,
        filteredMovements,
        filterCategoryId,
        filterType,
        filterStartDate,
        filterEndDate,
        error,
        successMessage,
      ];
}
