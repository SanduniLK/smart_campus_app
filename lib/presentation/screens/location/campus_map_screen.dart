// lib/presentation/screens/location/campus_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_campus_app/business_logic/map/campus_bloc.dart';
import 'package:smart_campus_app/business_logic/map/campus_event.dart';
import 'package:smart_campus_app/business_logic/map/campus_state.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/location/campus_building_model.dart';
import 'package:smart_campus_app/presentation/widgets/map/glass_search_bar.dart';
import 'package:smart_campus_app/presentation/widgets/map/glass_filter_chip.dart';

import 'package:smart_campus_app/presentation/widgets/map/building_detail_sheet.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  static const LatLng _campusCenter = LatLng(6.078547045423215, 80.56272600747548);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoadingLocation = true);
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Fixed: Use updated Geolocator API
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
      );
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      
      _animateToCurrentLocation();
      
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 18.0),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers(List<CampusBuilding> buildings) {
    Set<Marker> markers = {};
    
    for (var building in buildings) {
      markers.add(
        Marker(
          markerId: MarkerId(building.id),
          position: LatLng(building.latitude, building.longitude),
          infoWindow: InfoWindow(
            title: building.name,
            snippet: building.code,
          ),
          icon: _getMarkerIcon(building),
          onTap: () => _showBuildingDetails(building),
        ),
      );
    }
    
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_user'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          zIndexInt: 100,
        ),
      );
    }
    
    return markers;
  }

  BitmapDescriptor _getMarkerIcon(CampusBuilding building) {
    switch (building.type) {
      case 'academic': 
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'library': 
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'canteen': 
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'sports': 
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      default: 
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  void _showBuildingDetails(CampusBuilding building) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BuildingDetailSheet(building: building),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CampusBloc()..add(LoadBuildings()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A0E21),
                    const Color(0xFF1A1A3A),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            
            // Map
            BlocBuilder<CampusBloc, CampusState>(
              builder: (context, state) {
                if (state is CampusLoaded) {
                  final markers = _buildMarkers(state.filteredBuildings);
                  
                  return GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _campusCenter,
                      zoom: 15.5,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: true,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            
            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    // Title
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school, color: AppColors.electricPurple, size: 16),
                          const SizedBox(width: 8),
                          const Text('FOT Campus', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Location Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.white, size: 18),
                        onPressed: _getCurrentLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Search Bar
            Positioned(
              top: 110,
              left: 16,
              right: 16,
              child: GlassSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  // Search functionality
                },
              ),
            ),
            
            // Filter Chips
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: BlocBuilder<CampusBloc, CampusState>(
                builder: (context, state) {
                  if (state is! CampusLoaded) return const SizedBox();
                  
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GlassFilterChip(
                          label: 'All',
                          value: 'all',
                          selectedValue: state.selectedFilter,
                          onTap: () => context.read<CampusBloc>().add(FilterBuildings('all')),
                        ),
                        const SizedBox(width: 10),
                        GlassFilterChip(
                          label: 'Academic',
                          value: 'academic',
                          selectedValue: state.selectedFilter,
                          onTap: () => context.read<CampusBloc>().add(FilterBuildings('academic')),
                        ),
                        const SizedBox(width: 10),
                        GlassFilterChip(
                          label: 'Library',
                          value: 'library',
                          selectedValue: state.selectedFilter,
                          onTap: () => context.read<CampusBloc>().add(FilterBuildings('library')),
                        ),
                        const SizedBox(width: 10),
                        GlassFilterChip(
                          label: 'Canteen',
                          value: 'canteen',
                          selectedValue: state.selectedFilter,
                          onTap: () => context.read<CampusBloc>().add(FilterBuildings('canteen')),
                        ),
                        const SizedBox(width: 10),
                        GlassFilterChip(
                          label: 'Sports',
                          value: 'sports',
                          selectedValue: state.selectedFilter,
                          onTap: () => context.read<CampusBloc>().add(FilterBuildings('sports')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            
            
            
            // Loading Overlay
            if (_isLoadingLocation)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Finding your location...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}