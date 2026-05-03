// lib/domain/usecases/get_buildings_usecase.dart


import 'package:smart_campus_app/data/models/location/campus_building_model.dart';
import 'package:smart_campus_app/data/repositories/location/campus_repository.dart';

class GetBuildingsUseCase {
  final CampusRepository repository;

  GetBuildingsUseCase(this.repository);

  Future<List<CampusBuilding>> execute() {
    return repository.getAllBuildings();
  }
}