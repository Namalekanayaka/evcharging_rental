import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/search_bloc.dart';
import '../../data/entities/search_entities.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  late GoogleMapController _mapController;
  double? _userLat;
  double? _userLng;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
      _loadChargersNearby();
      _animateToUserLocation();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _loadChargersNearby() {
    if (_userLat == null || _userLng == null) return;

    final filters = SearchFilterEntity(
      latitude: _userLat,
      longitude: _userLng,
      radiusKm: 15,
      sortBy: 'distance',
      limit: 50,
    );

    context.read<SearchBloc>().add(SearchNearbyEvent(filters: filters));
  }

  Future<void> _animateToUserLocation() async {
    if (_userLat != null && _userLng != null) {
      await _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_userLat!, _userLng!),
          13,
        ),
      );
    }
  }

  void _addMarkersFromChargers(List<ChargerSearchResultEntity> chargers) {
    final newMarkers = <Marker>{};

    // User location marker
    if (_userLat != null && _userLng != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user-location'),
          position: LatLng(_userLat!, _userLng!),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    // Charger markers
    for (int i = 0; i < chargers.length; i++) {
      final charger = chargers[i];
      newMarkers.add(
        Marker(
          markerId: MarkerId('charger-${charger.id}'),
          position: LatLng(charger.latitude, charger.longitude),
          infoWindow: InfoWindow(
            title: charger.locationName,
            snippet:
                '${charger.availablePorts}/${charger.totalPorts} available',
            onTap: () {
              Navigator.pushNamed(
                context,
                '/charger-details',
                arguments: charger.id,
              );
            },
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            charger.availablePorts > 0
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    setState(() => _markers = newMarkers);
  }

  void _addRadiusCircle() {
    if (_userLat == null || _userLng == null) return;

    setState(() {
      _circles = {
        Circle(
          circleId: const CircleId('search-radius'),
          center: LatLng(_userLat!, _userLng!),
          radius: 15000, // 15 km in meters
          fillColor: Colors.blue.withValues(alpha: 0.1),
          strokeColor: Colors.blue.withValues(alpha: 0.3),
          strokeWidth: 2,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargers Map'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map
          BlocListener<SearchBloc, SearchState>(
            listener: (context, state) {
              if (state is SearchSuccessState) {
                _addMarkersFromChargers(state.chargers);
                _addRadiusCircle();
              } else if (state is SearchErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
                _animateToUserLocation();
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(_userLat ?? 0, _userLng ?? 0),
                zoom: 12,
              ),
              markers: _markers,
              circles: _circles,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          // Custom buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                // Zoom buttons
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.animateCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _mapController.animateCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: _animateToUserLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legend',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Your Location'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Available'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Full'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
