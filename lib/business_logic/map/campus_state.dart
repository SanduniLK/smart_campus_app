// lib/business_logic/map/campus_state.dart
import 'package:equatable/equatable.dart';
import 'package:smart_campus_app/data/models/location/campus_building_model.dart';

abstract class CampusState extends Equatable {
  const CampusState();

  @override
  List<Object?> get props => [];
}

class CampusInitial extends CampusState {}

class CampusLoading extends CampusState {}

class CampusLoaded extends CampusState {
  final List<CampusBuilding> buildings;
  final List<CampusBuilding> filteredBuildings;
  final String selectedFilter;
  
  const CampusLoaded({
    required this.buildings,
    required this.filteredBuildings,
    required this.selectedFilter,
  });
  
  @override
  List<Object> get props => [buildings, filteredBuildings, selectedFilter];
}

class CampusError extends CampusState {
  final String message;
  
  const CampusError(this.message);
  
  @override
  List<Object> get props => [message];
}