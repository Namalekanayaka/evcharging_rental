import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/charger/charger_bloc.dart';
import '../../domain/entities/charger_entity.dart';
import 'charger_detail_page.dart';

/// Charger Listing Page
/// Displays all available chargers with filtering and map view
class ChargerListingPage extends StatefulWidget {
  const ChargerListingPage({Key? key}) : super(key: key);

  @override
  State<ChargerListingPage> createState() => _ChargerListingPageState();
}

class _ChargerListingPageState extends State<ChargerListingPage> {
  final _searchController = TextEditingController();
  late GoogleMapController _mapController;
  
  String _selectedChargerType = 'ALL';
  String _sortBy = 'DISTANCE';
  bool _showMap = false;
  
  final List<String> chargerTypes = ['ALL', 'AC', 'DC', 'FAST'];
  final List<String> sortOptions = ['DISTANCE', 'RATING', 'PRICE', 'NEWEST'];

  @override
  void initState() {
    super.initState();
    // Load chargers on page init
    context.read<ChargerBloc>().add(const SearchChargersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter chargers based on search and filters
  void _applyFilters() {
    context.read<ChargerBloc>().add(
      SearchChargersEvent(
        city: _searchController.text.isNotEmpty ? _searchController.text : null,
        chargerType: _selectedChargerType != 'ALL' ? _selectedChargerType : null,
        sortBy: _sortBy,
      ),
    );
  }

  /// Build charger card for list view
  Widget _buildChargerCard(ChargerEntity charger) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChargerDetailPage(chargerId: charger.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Charger name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      charger.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: charger['status'] == 'ACTIVE'
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      charger['status'] ?? 'OFFLINE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: charger['status'] == 'ACTIVE'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Charger type and power
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      charger['chargerType'] ?? 'AC',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${charger['powerKw'] ?? 0} kW',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Text(
                charger['city'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Rating and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${charger['avgRating']?.toStringAsFixed(1) ?? 'N/A'} (${charger['totalReviews'] ?? 0})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  // Price
                  Text(
                    charger['pricePerKwh'] != null
                        ? '\$${charger['pricePerKwh']?.toStringAsFixed(2)}/kWh'
                        : 'Contact',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Charger type filter
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              initialValue: _selectedChargerType,
              decoration: InputDecoration(
                labelText: 'Charger Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: chargerTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedChargerType = value);
                  _applyFilters();
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Sort filter
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: sortOptions
                  .map((sort) => DropdownMenuItem(
                        value: sort,
                        child: Text(sort),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortBy = value);
                  _applyFilters();
                }
              },
            ),
          ),
          const SizedBox(width: 12),

          // Toggle map view
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
            icon: Icon(_showMap ? Icons.list : Icons.map),
            label: Text(_showMap ? 'List' : 'Map'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Chargers'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                _applyFilters();
              },
            ),
          ),

          // Filter bar
          _buildFilterBar(),

          // Content
          Expanded(
            child: BlocBuilder<ChargerBloc, ChargerState>(
              builder: (context, state) {
                if (state is ChargerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ChargersLoaded) {
                  final chargers = state.chargers;

                  if (chargers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.electric_car,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chargers found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search filters',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_showMap) {
                    // Map view
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          chargers.first.latitude,
                          chargers.first.longitude,
                        ),
                        zoom: 12,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      markers: chargers
                          .map(
                            (charger) => Marker(
                              markerId: MarkerId(charger.id.toString()),
                              position: LatLng(
                                charger['latitude'] ?? 0,
                                charger['longitude'] ?? 0,
                              ),
                              infoWindow: InfoWindow(
                                title: charger['name'],
                                snippet: charger['city'],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChargerDetailPage(chargerId: charger['id']),
                                  ),
                                );
                              },
                            ),
                          )
                          .toSet(),
                    );
                  } else {
                    // List view
                    return ListView.builder(
                      itemCount: chargers.length,
                      itemBuilder: (context, index) {
                        return _buildChargerCard(chargers[index]);
                      },
                    );
                  }
                }

                if (state is ChargerFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading chargers',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ChargerBloc>()
                                .add(const SearchChargersEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/add-charger');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Charger'),
      ),
    );
  }
}
