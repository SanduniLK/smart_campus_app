// lib/business_logic/map/campus_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'campus_event.dart';
import 'campus_state.dart';
import 'package:smart_campus_app/data/models/location/campus_building_model.dart';

class CampusBloc extends Bloc<CampusEvent, CampusState> {
  final List<CampusBuilding> _allBuildings = [
    CampusBuilding(
      id: 'fot_main',
      name: 'Faculty of Technology',
      code: 'FOT',
      latitude: 6.078547045423215,
      longitude: 80.56272600747548,
      type: 'academic',
      color: Colors.blue,
      icon: Icons.school,
      description: 'Main Faculty of Technology Building',
      facilities: ['Lecture Halls', 'Computer Labs', 'Faculty Offices', 'Seminar Rooms'],
    ),
    CampusBuilding(
      id: 'library',
      name: 'Library',
      code: 'LIB',
      latitude: 6.063079348339263,
      longitude: 80.54074078262924,
      type: 'library',
      color: Colors.purple,
      icon: Icons.local_library,
      description: 'University Library',
      facilities: ['Reading Rooms', 'Digital Library', 'Study Areas', 'WiFi'],
    ),
    CampusBuilding(
      id: 'canteen',
      name: 'Canteen',
      code: 'CAN',
      latitude: 6.063375954300081,
      longitude: 80.54162876405633,
      type: 'canteen',
      color: Colors.orange,
      icon: Icons.restaurant,
      description: 'University Canteen',
      facilities: ['Food Court', 'Beverages', 'Snacks', 'Seating Area'],
    ),
    CampusBuilding(
      id: 'union_office',
      name: 'Union Office',
      code: 'UOF',
      latitude: 6.063322591502891,
      longitude: 80.5403782094091,
      type: 'admin',
      color: Colors.cyan,
      icon: Icons.group,
      description: 'Student Union Office',
      facilities: ['Student Services', 'Meeting Rooms', 'Event Planning'],
    ),
    CampusBuilding(
      id: 'auditorium',
      name: 'Auditorium',
      code: 'AUD',
      latitude: 6.0647182072562105,
      longitude: 80.54083752650916,
      type: 'academic',
      color: Colors.green,
      icon: Icons.theaters,
      description: 'Main Auditorium',
      facilities: ['Stage', 'Seating', 'AC', 'Sound System'],
    ),
    CampusBuilding(
      id: 'gym',
      name: 'Gymnasium',
      code: 'GYM',
      latitude: 6.0624875387495685,
      longitude: 80.5402964015156,
      type: 'sports',
      color: Colors.red,
      icon: Icons.fitness_center,
      description: 'University Gym',
      facilities: ['Equipment', 'Lockers', 'Trainers', 'Showers'],
    ),
    CampusBuilding(
      id: 'study_area',
      name: 'Study Area',
      code: 'STD',
      latitude: 6.063780983100893,
      longitude: 80.54019989353097,
      type: 'academic',
      color: Colors.teal,
      icon: Icons.auto_stories,
      description: 'Student Study Area',
      facilities: ['Study Tables', 'Power Outlets', 'WiFi', 'AC'],
    ),
  ];

  CampusBloc() : super(CampusInitial()) {
    on<LoadBuildings>(_onLoadBuildings);
    on<FilterBuildings>(_onFilterBuildings);
  }

  Future<void> _onLoadBuildings(
    LoadBuildings event,
    Emitter<CampusState> emit,
  ) async {
    emit(CampusLoading());
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    emit(CampusLoaded(
      buildings: _allBuildings,
      filteredBuildings: _allBuildings,
      selectedFilter: 'all',
    ));
  }

  void _onFilterBuildings(
    FilterBuildings event,
    Emitter<CampusState> emit,
  ) {
    if (state is CampusLoaded) {
      final currentState = state as CampusLoaded;
      final filtered = event.filter == 'all'
          ? currentState.buildings
          : currentState.buildings.where((b) => b.type == event.filter).toList();
      
      emit(CampusLoaded(
        buildings: currentState.buildings,
        filteredBuildings: filtered,
        selectedFilter: event.filter,
      ));
    }
  }
}