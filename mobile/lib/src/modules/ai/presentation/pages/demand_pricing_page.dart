import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ai/presentation/bloc/ai_bloc.dart';

class DemandPricingPage extends StatefulWidget {
  const DemandPricingPage({Key? key}) : super(key: key);

  @override
  State<DemandPricingPage> createState() => _DemandPricingPageState();
}

class _DemandPricingPageState extends State<DemandPricingPage> {
  final _chargerIdController = TextEditingController();

  @override
  void dispose() {
    _chargerIdController.dispose();
    super.dispose();
  }

  void _predictPricing() {
    if (_chargerIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter charger ID')),
      );
      return;
    }

    context.read<AIBloc>().add(
          PredictDemandPricingEvent(
            int.parse(_chargerIdController.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demand-Based Pricing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Charger',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _chargerIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter charger ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _predictPricing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Get Pricing Prediction', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),

            BlocBuilder<AIBloc, AIState>(
              builder: (context, state) {
                if (state is AILoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DemandPricingPredictedState) {
                  final pricing = state.pricing;
                  final multiplierColor = pricing.demandMultiplier > 1.25
                      ? Colors.red
                      : pricing.demandMultiplier > 1.0
                          ? Colors.orange
                          : Colors.green;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pricing Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Price Cards
                      Row(
                        children: [
                          Expanded(
                            child: _PriceCard(
                              label: 'Current Price',
                              price: '₹${pricing.currentPrice.toStringAsFixed(2)}',
                              color: Colors.blue[100]!,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PriceCard(
                              label: 'Predicted Price',
                              price: '₹${pricing.predictedPrice.toStringAsFixed(2)}',
                              color: multiplierColor[100]!,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Demand Level
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: multiplierColor[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: multiplierColor[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Demand Level',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: multiplierColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    pricing.demandLevel.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Multiplier: ${pricing.demandMultiplier.toStringAsFixed(2)}x',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Time Information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            _DetailRow(
                              label: 'Hour of Day',
                              value: '${pricing.hour}:00',
                              icon: Icons.access_time,
                            ),
                            const Divider(),
                            _DetailRow(
                              label: 'Day of Week',
                              value: _getDayName(pricing.dayOfWeek),
                              icon: Icons.calendar_today,
                            ),
                            const Divider(),
                            _DetailRow(
                              label: 'Forecasted Occupancy',
                              value: '${pricing.forecastedOccupancy} slots',
                              icon: Icons.people,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recommendation
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              pricing.demandMultiplier < 1.0 ? Icons.thumb_up : Icons.info,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                pricing.demandMultiplier < 1.0
                                    ? 'Great time to charge! Low demand = discounted rates'
                                    : pricing.demandMultiplier < 1.25
                                        ? 'Average demand. Prices stable.'
                                        : 'High demand. Expect elevated prices.',
                                style: const TextStyle(fontSize: 14),
                              ),
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

  String _getDayName(int dayOfWeek) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek % 7];
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String price;
  final Color color;

  const _PriceCard({
    required this.label,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
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
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
