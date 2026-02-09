import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai/presentation/bloc/ai_bloc.dart';

class BatteryRangePage extends StatefulWidget {
  const BatteryRangePage({Key? key}) : super(key: key);

  @override
  State<BatteryRangePage> createState() => _BatteryRangePageState();
}

class _BatteryRangePageState extends State<BatteryRangePage> {
  final _carModelController = TextEditingController();
  final _batteryController = TextEditingController();
  String _selectedWeather = 'normal';

  final List<String> carModels = ['sedan', 'suv', 'hatchback', 'van', 'truck'];
  final List<String> weatherOptions = ['normal', 'rainy', 'snowy', 'sunny'];

  @override
  void dispose() {
    _carModelController.dispose();
    _batteryController.dispose();
    super.dispose();
  }

  void _predictBatteryRange() {
    if (_carModelController.text.isEmpty || _batteryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<AIBloc>().add(
          PredictBatteryRangeEvent(
            _carModelController.text,
            double.parse(_batteryController.text),
            weather: _selectedWeather,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Range Prediction'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Model Selection
            const Text(
              'Select Car Model',
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

            // Current Battery Input
            const Text(
              'Current Battery Percentage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _batteryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter battery percentage (0-100)',
                suffixText: '%',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 20),

            // Weather Condition
            const Text(
              'Weather Condition',
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

            // Predict Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _predictBatteryRange,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    const Text('Predict Range', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),

            // Results
            BlocBuilder<AIBloc, AIState>(
              builder: (context, state) {
                if (state is AILoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BatteryRangePredictedState) {
                  final entity = state.batteryRange;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prediction Results',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[300]!),
                        ),
                        child: Column(
                          children: [
                            _ResultRow(
                              label: 'Predicted Range',
                              value: '${entity.predictedRange} km',
                              icon: Icons.location_on,
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Current Battery',
                              value: '${entity.currentBattery}%',
                              icon: Icons.battery_std,
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Full Charge Range',
                              value: '${entity.fullChargeRange} km',
                              icon: Icons.electric_car,
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Weather Factor',
                              value: entity.weatherFactor,
                              icon: Icons.cloud,
                            ),
                            const Divider(),
                            _ResultRow(
                              label: 'Efficiency',
                              value: '${entity.efficiency} km/%',
                              icon: Icons.trending_up,
                            ),
                          ],
                        ),
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

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
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
