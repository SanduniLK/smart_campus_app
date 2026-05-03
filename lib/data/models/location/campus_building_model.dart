// lib/domain/entities/campus_building.dart
import 'package:flutter/material.dart';

class CampusBuilding {
  final String id;
  final String name;
  final String code;
  final double latitude;
  final double longitude;
  final String type;
  final Color color;
  final IconData icon;
  final String description;
  final List<String> facilities;

  const CampusBuilding({
    required this.id,
    required this.name,
    required this.code,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.color,
    required this.icon,
    this.description = '',
    this.facilities = const [],
  });
}