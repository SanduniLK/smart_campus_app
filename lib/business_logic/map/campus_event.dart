// lib/business_logic/map/campus_event.dart
import 'package:equatable/equatable.dart';

abstract class CampusEvent extends Equatable {
  const CampusEvent();

  @override
  List<Object?> get props => [];
}

class LoadBuildings extends CampusEvent {}

class FilterBuildings extends CampusEvent {
  final String filter;
  
  const FilterBuildings(this.filter);
  
  @override
  List<Object> get props => [filter];
}