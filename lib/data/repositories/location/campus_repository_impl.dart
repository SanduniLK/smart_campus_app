// lib/data/repositories/campus_repository_impl.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/data/models/location/campus_building_model.dart';
import 'package:smart_campus_app/data/repositories/location/campus_repository.dart';



class CampusRepositoryImpl implements CampusRepository {
  // Your existing buildings data
  static const List<CampusBuilding> _buildings = [
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
      color: Colors.blue,
      icon: Icons.theaters,
      description: 'Main Auditorium',
      facilities: ['Stage', 'Seating', 'AC', 'Sound System'],
    ),
    CampusBuilding(
      id: 'back_gate',
      name: 'Back Gate',
      code: 'BGT',
      latitude: 6.064508639703759,
      longitude: 80.5393469111285,
      type: 'admin',
      color: Colors.grey,
      icon: Icons.fence,
      description: 'Back Entrance Gate',
      facilities: ['Security Post', 'Vehicle Entrance'],
    ),
    CampusBuilding(
      id: 'maintenance',
      name: 'Maintenance Unit',
      code: 'MTU',
      latitude: 6.063906554351908,
      longitude: 80.53974783758092,
      type: 'admin',
      color: Colors.grey,
      icon: Icons.build,
      description: 'Maintenance Department',
      facilities: ['Repair Workshop', 'Storage', 'Vehicle Maintenance'],
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
      color: Colors.blue,
      icon: Icons.auto_stories,
      description: 'Student Study Area',
      facilities: ['Study Tables', 'Power Outlets', 'WiFi', 'AC'],
    ),
  ];

  @override
  Future<List<CampusBuilding>> getAllBuildings() async {
    return _buildings;
  }

  @override
  Future<CampusBuilding?> getBuildingById(String id) async {
    return _buildings.firstWhere((b) => b.id == id);
  }
}