// lib/domain/repositories/campus_repository.dart
import 'package:smart_campus_app/data/models/location/campus_building_model.dart';



abstract class CampusRepository {
  Future<List<CampusBuilding>> getAllBuildings();
  Future<CampusBuilding?> getBuildingById(String id);
}