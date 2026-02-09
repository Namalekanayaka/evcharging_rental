import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/search_bloc.dart';
import '../../data/entities/search_entities.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({Key? key}) : super(key: key);

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  double? _userLat;
  double? _userLng;
  int _batteryPercentage = 50;
  bool _urgentCharging = false;

  @override
  void initState() {
    super.initState();
    _getUserLocationAndLoadRecommendation();
  }

  Future<void> _getUserLocationAndLoadRecommendation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
      _loadRecommendation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  void _loadRecommendation() {
    if (_userLat == null || _userLng == null) return;

    context.read<SearchBloc>().add(
      GetRecommendationEvent(
        latitude: _userLat!,
        longitude: _userLng!,
        batteryPercentage: _batteryPercentage,
        urgentCharging: _urgentCharging,
      ),
    );
  }

  Future<void> _openNavigation(
    double latitude,
    double longitude,
  ) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Charger'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Battery and Urgency Settings
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery Level: $_batteryPercentage%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _batteryPercentage.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (value) {
                          setState(() => _batteryPercentage = value.toInt());
                          _loadRecommendation();
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Urgent Charging'),
                        subtitle: const Text('Need to charge quickly'),
                        value: _urgentCharging,
                        onChanged: (value) {
                          setState(
                              () => _urgentCharging = value ?? false);
                          _loadRecommendation();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Recommendation Result
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RecommendationSuccessState) {
                    final charger = state.charger;
                    if (charger == null) {
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
                              'No chargers available',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    return RecommendationCard(
                      charger: charger,
                      onNavigate: () => _openNavigation(
                        charger.latitude,
                        charger.longitude,
                      ),
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
      ),
    );
  }
}

class RecommendationCard extends StatefulWidget {
  final ChargerSearchResultEntity charger;
  final VoidCallback onNavigate;

  const RecommendationCard({
    Key? key,
    required this.charger,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        widget.charger.locationName,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.charger.address,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          widget.charger.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Key Stats Grid
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  icon: Icons.location_on,
                  label: 'Distance',
                  value:
                      '${widget.charger.distanceKm.toStringAsFixed(1)} km',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.bolt,
                  label: 'Power',
                  value: '${widget.charger.powerOutput}kW',
                  color: Colors.deepOrange,
                ),
                _StatCard(
                  icon: Icons.local_gasstation,
                  label: 'Price',
                  value:
                      '\$${widget.charger.pricePerKwh.toStringAsFixed(2)}',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.charging_station,
                  label: 'Available',
                  value:
                      '${widget.charger.availablePorts}/${widget.charger.totalPorts}',
                  color: Colors.purple,
                ),
                _StatCard(
                  icon: Icons.person,
                  label: 'Owner',
                  value: widget.charger.ownerName,
                  color: Colors.teal,
                ),
                _StatCard(
                  icon: Icons.info,
                  label: 'Type',
                  value: widget.charger.chargerType,
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onNavigate,
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/charger-details',
                        arguments: widget.charger.id,
                      );
                    },
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/booking',
                    arguments: widget.charger.id,
                  );
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
