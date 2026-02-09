import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai/presentation/bloc/ai_bloc.dart';

class ChargerRecommendationsPage extends StatefulWidget {
  const ChargerRecommendationsPage({Key? key}) : super(key: key);

  @override
  State<ChargerRecommendationsPage> createState() =>
      _ChargerRecommendationsPageState();
}

class _ChargerRecommendationsPageState
    extends State<ChargerRecommendationsPage> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _batteryController = TextEditingController();
  final _carModelController = TextEditingController();
  String _selectedWeather = 'normal';

  final List<String> carModels = ['sedan', 'suv', 'hatchback', 'van', 'truck'];
  final List<String> weatherOptions = ['normal', 'rainy', 'snowy', 'sunny'];

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _batteryController.dispose();
    _carModelController.dispose();
    super.dispose();
  }

  void _findChargers() {
    if (_latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty ||
        _batteryController.text.isEmpty ||
        _carModelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<AIBloc>().add(
          FindNearestChargersEvent(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
            double.parse(_batteryController.text),
            _carModelController.text,
            weather: _selectedWeather,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearest Chargers'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Input
            const Text(
              'Your Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Latitude',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Longitude',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Car Model
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

            // Current Battery
            const Text(
              'Current Battery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batteryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Battery percentage (0-100)',
                suffixText: '%',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),

            // Weather
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

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _findChargers,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    const Text('Find Chargers', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),

            // Results
            BlocBuilder<AIBloc, AIState>(
              builder: (context, state) {
                if (state is AILoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NearestChargersFoundState) {
                  final chargers = state.chargers;
                  if (chargers.isEmpty) {
                    return const Center(
                      child: Text('No chargers found within your range'),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Found ${chargers.length} Chargers',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chargers.length,
                        itemBuilder: (context, index) {
                          final charger = chargers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              charger.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              charger.location,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[100],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Score: ${charger.score}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _ChargerInfo(
                                        icon: Icons.location_on,
                                        label:
                                            '${charger.distanceKm.toStringAsFixed(1)} km',
                                      ),
                                      _ChargerInfo(
                                        icon: Icons.electric_car,
                                        label: charger.chargerType,
                                      ),
                                      _ChargerInfo(
                                        icon: Icons.attach_money,
                                        label: '₹${charger.pricePerKwh}/kWh',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            charger.avgRating
                                                    ?.toStringAsFixed(1) ??
                                                'N/A',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: charger.willReachWithBuffer
                                              ? Colors.green[100]
                                              : Colors.orange[100],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          charger.willReachWithBuffer
                                              ? '✓ Reachable'
                                              : '⚠ Low Buffer',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: charger.willReachWithBuffer
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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

class _ChargerInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ChargerInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
