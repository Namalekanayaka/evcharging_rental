import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/search_bloc.dart';
import '../../data/entities/search_entities.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late SearchFilterEntity _filters;

  double? _userLat;
  double? _userLng;

  // Filters
  String _sortBy = 'distance';
  double _minPrice = 0;
  double _maxPrice = 100;
  int _minPower = 0;
  bool _availableOnly = true;
  final List<String> _selectedChargerTypes = [];

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
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _performSearch() {
    if (_userLat == null || _userLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get your location')),
      );
      return;
    }

    _filters = SearchFilterEntity(
      latitude: _userLat,
      longitude: _userLng,
      radiusKm: 10,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      chargerTypes: _selectedChargerTypes,
      minPower: _minPower,
      availability: _availableOnly,
      sortBy: _sortBy,
      limit: 20,
    );

    context.read<SearchBloc>().add(SearchNearbyEvent(filters: _filters));
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                // Price Range
                Text(
                    'Price Range: \$${_minPrice.toStringAsFixed(2)} - \$${_maxPrice.toStringAsFixed(2)}/kWh'),
                RangeSlider(
                  values: RangeValues(_minPrice, _maxPrice),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (RangeValues values) {
                    setModalState(() {
                      _minPrice = values.start;
                      _maxPrice = values.end;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Min Power
                Text('Min Power: ${_minPower}kW'),
                Slider(
                  value: _minPower.toDouble(),
                  min: 0,
                  max: 300,
                  divisions: 30,
                  onChanged: (value) {
                    setModalState(() => _minPower = value.toInt());
                  },
                ),
                const SizedBox(height: 20),
                // Charger Types
                const Text('Charger Types:'),
                Wrap(
                  spacing: 8,
                  children: ['Type 1', 'Type 2', 'CCS', 'Tesla', 'CHAdeMO']
                      .map((type) {
                    return FilterChip(
                      label: Text(type),
                      selected: _selectedChargerTypes.contains(type),
                      onSelected: (selected) {
                        setModalState(() {
                          if (selected) {
                            _selectedChargerTypes.add(type);
                          } else {
                            _selectedChargerTypes.remove(type);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Availability
                CheckboxListTile(
                  title: const Text('Available Only'),
                  value: _availableOnly,
                  onChanged: (value) {
                    setModalState(() => _availableOnly = value ?? true);
                  },
                ),
                const SizedBox(height: 20),
                // Sort By
                const Text('Sort By:'),
                DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'distance', child: Text('Distance')),
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(
                        value: 'availability', child: Text('Availability')),
                  ],
                  onChanged: (value) {
                    setModalState(() => _sortBy = value ?? 'distance');
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _performSearch();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by location...',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _showFilterModal,
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchInitialState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for chargers nearby',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                } else if (state is SearchLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SearchSuccessState) {
                  if (state.chargers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chargers found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.chargers.length,
                    itemBuilder: (context, index) {
                      final charger = state.chargers[index];
                      return ChargerSearchCard(charger: charger);
                    },
                  );
                } else if (state is SearchErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ChargerSearchCard extends StatelessWidget {
  final ChargerSearchResultEntity charger;

  const ChargerSearchCard({
    Key? key,
    required this.charger,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to charger details
          Navigator.pushNamed(
            context,
            '/charger-details',
            arguments: charger.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          charger.locationName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          charger.address,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${charger.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            charger.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Power
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      const Icon(Icons.bolt,
                          size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text('${charger.powerOutput}kW'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Price
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      const Icon(Icons.power, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text('\$${charger.pricePerKwh.toStringAsFixed(2)}/kWh'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Availability
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: charger.availablePorts > 0
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${charger.availablePorts}/${charger.totalPorts}',
                        style: TextStyle(
                          fontSize: 12,
                          color: charger.availablePorts > 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
