import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pricing_bloc.dart';
import '../../domain/entities/pricing_entities.dart';

/// Pricing Packages Page
/// Displays available subscription packages
class PricingPackagesPage extends StatefulWidget {
  const PricingPackagesPage({Key? key}) : super(key: key);

  @override
  State<PricingPackagesPage> createState() => _PricingPackagesPageState();
}

class _PricingPackagesPageState extends State<PricingPackagesPage> {
  String _selectedBillingCycle = 'monthly';
  int? _selectedPackageId;

  @override
  void initState() {
    super.initState();
    context.read<PricingBloc>().add(const GetPricingPackagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        elevation: 0,
      ),
      body: BlocBuilder<PricingBloc, PricingState>(
        builder: (context, state) {
          if (state is PricingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PricingPackagesSuccessState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Billing cycle toggle
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(label: Text('Monthly'), value: 'monthly'),
                        ButtonSegment(label: Text('Annual'), value: 'annual'),
                      ],
                      selected: {_selectedBillingCycle},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedBillingCycle = newSelection.first;
                        });
                      },
                    ),
                  ),

                  // Package cards
                  ...state.packages
                      .map((package) => _buildPackageCard(context, package))
                      .toList(),
                ],
              ),
            );
          }

          if (state is PricingErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PricingBloc>()
                          .add(const GetPricingPackagesEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No packages available'));
        },
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, PricingPackageEntity package) {
    final price = _selectedBillingCycle == 'annual'
        ? package.annualPrice
        : package.monthlyPrice;
    final isSelected = _selectedPackageId == package.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tier: ${package.tier}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      _selectedBillingCycle == 'annual' ? '/year' : '/month',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Commission Rate: ${package.commissionRate}%',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: package.features.map((feature) {
                return Chip(
                  label: Text(feature, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _selectedPackageId = package.id);
                  context.read<PricingBloc>().add(
                        SubscribeToPackageEvent(
                            package.id, _selectedBillingCycle),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.green : Colors.blue,
                ),
                child: Text(isSelected ? 'Subscribe now' : 'Select plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
