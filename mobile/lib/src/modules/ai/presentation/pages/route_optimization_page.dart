import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../ai/presentation/bloc/ai_bloc.dart';

class RouteOptimizationPage extends StatefulWidget {
  const RouteOptimizationPage({Key? key}) : super(key: key);

  @override
  State<RouteOptimizationPage> createState() => _RouteOptimizationPageState();
}

class _RouteOptimizationPageState extends State<RouteOptimizationPage> {
  final _carModelController = TextEditingController();
  final _batteryController = TextEditingController();
  final _locationsController = TextEditingController();
  String _selectedWeather = 'normal';

  final List<String> carModels = ['sedan', 'suv', 'hatchback', 'van', 'truck'];
  final List<String> weatherOptions = ['normal', 'rainy', 'snowy', 'sunny'];

  @override
  void dispose() {
    _carModelController.dispose();
    _batteryController.dispose();
    _locationsController.dispose();
    super.dispose();
  }

  void _optimizeRoute() {
    if (_carModelController.text.isEmpty ||
        _batteryController.text.isEmpty ||
        _locationsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final locationsJson = jsonDecode(_locationsController.text);
      if (locationsJson is! List) {
        throw const FormatException('Locations must be a JSON array');
      }

      context.read<AIBloc>().add(
            OptimizeRouteEvent(
              List<Map<String, dynamic>>.from(locationsJson),
              _carModelController.text,
              double.parse(_batteryController.text),
              weather: _selectedWeather,
            ),
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON format: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Optimization'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Model',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _carModelController.text.isEmpty
                  ? null
                  : _carModelController.text,
              items: carModels.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _carModelController.text = value;
                }
              },
              decoration: InputDecoration(
                hintText: 'Choose a car model',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Current Battery %',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batteryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Battery percentage',
                suffixText: '%',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Locations (JSON Array)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationsController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    '[{"name": "Start", "latitude": 0, "longitude": 0}, ...]',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Example: [{"name": "Location 1", "latitude": 40.7128, "longitude": -74.0060}]',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            const Text(
              'Weather',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: weatherOptions.map((weather) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(weather.toUpperCase()),
                      selected: _selectedWeather == weather,
                      onSelected: (selected) {
                        setState(() => _selectedWeather = weather);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _optimizeRoute,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Calculate Route',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
            BlocBuilder<AIBloc, AIState>(
              builder: (context, state) {
                if (state is AILoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RouteOptimizedState) {
                  final route = state.route;
                  final stops = route.optimizedRoute;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Optimized Route',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Summary Cards
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                              icon: Icons.timer,
                              label: 'Total Time',
                              value: '${route.totalTimeMinutes} min',
                            ),
                            const Divider(),
                            _SummaryRow(
                              icon: Icons.location_on,
                              label: 'Waypoints',
                              value: '${route.waypoints}',
                            ),
                            const Divider(),
                            _SummaryRow(
                              icon: Icons.trending_up,
                              label: 'Efficiency',
                              value: route.efficiency,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Route Steps
                      const Text(
                        'Route Steps',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stops.length,
                        itemBuilder: (context, index) {
                          final stop = stops[index];
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: stop.type == 'destination'
                                            ? Colors.green
                                            : Colors.blue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (stop.charger ?? 'Unknown')
                                                .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.battery_std,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Arrival: ${stop.arrivalBattery}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              if (stop.chargingTimeMinutes !=
                                                  null) ...[
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.timer,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Charge: ${stop.chargingTimeMinutes} min',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < stops.length - 1)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: Colors.grey[400],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                }

                if (state is AIErrorState) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
