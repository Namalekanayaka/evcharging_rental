import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pricing_bloc.dart';
import '../../domain/entities/pricing_entities.dart';

/// Commission Breakdown Page
/// Displays charger owner's earnings and commission breakdown
class CommissionBreakdownPage extends StatefulWidget {
  const CommissionBreakdownPage({Key? key}) : super(key: key);

  @override
  State<CommissionBreakdownPage> createState() =>
      _CommissionBreakdownPageState();
}

class _CommissionBreakdownPageState extends State<CommissionBreakdownPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadCommissionBreakdown();
  }

  void _loadCommissionBreakdown() {
    context.read<PricingBloc>().add(
          GetCommissionBreakdownEvent(
            month: _selectedDate.month,
            year: _selectedDate.year,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commission Breakdown'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Month selector
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month - 1,
                              );
                              _loadCommissionBreakdown();
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month + 1,
                              );
                              _loadCommissionBreakdown();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Commission data
            BlocBuilder<PricingBloc, PricingState>(
              builder: (context, state) {
                if (state is PricingLoadingState) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is CommissionBreakdownSuccessState) {
                  return _buildContent(state.breakdown);
                }

                if (state is PricingErrorState) {
                  return SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                        ],
                      ),
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

  Widget _buildContent(List<CommissionBreakdownEntity> breakdowns) {
    if (breakdowns.isEmpty) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No commission data for this period'),
            ],
          ),
        ),
      );
    }

    final totalRevenue = breakdowns.fold<double>(
      0,
      (prev, current) => prev + current.totalRevenue,
    );
    final totalEarnings = breakdowns.fold<double>(
      0,
      (prev, current) => prev + current.ownerEarnings,
    );
    final totalCommission = totalRevenue - totalEarnings;

    return Column(
      children: [
        // Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Your Earnings',
                  '\$${totalEarnings.toStringAsFixed(2)}',
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSummaryCard(
            'Platform Commission',
            '\$${totalCommission.toStringAsFixed(2)}',
            Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        // Detailed breakdown table
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Charger Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Charger')),
                      DataColumn(label: Text('Revenue'), numeric: true),
                      DataColumn(label: Text('Commission %'), numeric: true),
                      DataColumn(label: Text('Commission'), numeric: true),
                      DataColumn(label: Text('Your Earnings'), numeric: true),
                    ],
                    rows: breakdowns.map((breakdown) {
                      final commission = breakdown.totalRevenue *
                          (breakdown.commissionRate / 100);
                      return DataRow(cells: [
                        DataCell(Text(breakdown.chargerName)),
                        DataCell(Text(
                            '\$${breakdown.totalRevenue.toStringAsFixed(2)}')),
                        DataCell(Text(
                            '${breakdown.commissionRate.toStringAsFixed(0)}%')),
                        DataCell(Text('\$${commission.toStringAsFixed(2)}')),
                        DataCell(Text(
                            '\$${breakdown.ownerEarnings.toStringAsFixed(2)}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Chart section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Revenue Distribution',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDistributionBar(
                          'Your Earnings',
                          totalEarnings,
                          totalRevenue,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDistributionBar(
                          'Platform Commission',
                          totalCommission,
                          totalRevenue,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(
    String label,
    double value,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (value / total) * 100 : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / total,
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}% (\$${value.toStringAsFixed(2)})',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
