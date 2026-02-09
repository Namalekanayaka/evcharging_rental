import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../admin/presentation/bloc/admin_bloc.dart';

class AdminChargersPage extends StatefulWidget {
  const AdminChargersPage({Key? key}) : super(key: key);

  @override
  State<AdminChargersPage> createState() => _AdminChargersPageState();
}

class _AdminChargersPageState extends State<AdminChargersPage> {
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  final int _limit = 20;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _loadChargers();
  }

  void _loadChargers() {
    final filters = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) {
      filters['search'] = _searchController.text;
    }
    if (_filterStatus != 'all') {
      filters['approvalStatus'] = _filterStatus == 'approved';
    }

    context.read<AdminBloc>().add(
          GetChargersEvent(
            _limit,
            _offset,
            filters: filters.isNotEmpty ? filters : null,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Chargers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChargers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search chargers by name or location',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadChargers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (_) => _loadChargers(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _filterStatus,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Chargers'),
                          ),
                          DropdownMenuItem(
                            value: 'approved',
                            child: Text('Approved'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending Approval'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value ?? 'all';
                            _offset = 0;
                          });
                          _loadChargers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chargers List
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChargersLoadedState) {
                  final chargers = state.chargers;

                  if (chargers.isEmpty) {
                    return Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No chargers found'
                            : 'No chargers match your search',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: chargers.length,
                    itemBuilder: (context, index) {
                      final charger = chargers[index];
                      return _ChargerCard(charger: charger);
                    },
                  );
                }

                if (state is AdminErrorState) {
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
          ),
        ],
      ),
    );
  }
}

class _ChargerCard extends StatelessWidget {
  final dynamic charger;

  const _ChargerCard({required this.charger});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                        charger.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: charger.isApproved
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        charger.isApproved ? 'Approved' : 'Pending',
                        style: TextStyle(
                          color: charger.isApproved
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: charger.isActive
                            ? Colors.blue[100]
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        charger.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: charger.isActive
                              ? Colors.blue[700]
                              : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ChargerInfo(
                  icon: Icons.ev_station,
                  value: charger.chargerType,
                ),
                _ChargerInfo(
                  icon: Icons.attach_money,
                  value: '₹${charger.pricePerKwh}/kWh',
                ),
                _ChargerInfo(
                  icon: Icons.star,
                  value: charger.avgRating != null
                      ? '${charger.avgRating.toStringAsFixed(1)}/5'
                      : 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Owner: ${charger.ownerName ?? 'Unknown'} (${charger.ownerEmail ?? 'N/A'})',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!charger.isApproved)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showApproveDialog(context, charger),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                if (!charger.isApproved) const SizedBox(width: 8),
                if (!charger.isApproved)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(context, charger),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                if (charger.isApproved)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Action for approved chargers
                      },
                      child: const Text('View Details'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, dynamic charger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Charger'),
        content: Text('Approve ${charger.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(
                    ApproveChargerEvent(
                      charger.id,
                      approved: true,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, dynamic charger) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Charger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejecting ${charger.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminBloc>().add(
                    ApproveChargerEvent(
                      charger.id,
                      approved: false,
                      reason: reasonController.text,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ChargerInfo extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ChargerInfo({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
