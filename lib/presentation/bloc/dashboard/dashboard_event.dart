// lib/presentation/bloc/dashboard/dashboard_event.dart
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class LoadDashboardForMonth extends DashboardEvent {
  final int month;
  final int year;

  const LoadDashboardForMonth({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}
