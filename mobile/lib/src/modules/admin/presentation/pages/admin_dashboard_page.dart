import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../admin/presentation/bloc/admin_bloc.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const GetPlatformAnalyticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminBloc>().add(const GetPlatformAnalyticsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PlatformAnalytticsLoadedState) {
            final analytics = state.summary;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Text(
                    'Platform Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _StatCard(
                        label: 'Total Users',
                        value: '${analytics.totalUsers}',
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        label: 'Active Chargers',
                        value: '${analytics.totalChargers}',
                        icon: Icons.electric_car,
                        color: Colors.green,
                      ),
                      _StatCard(
                        label: 'Completed Bookings',
                        value: '${analytics.totalBookings}',
                        icon: Icons.calendar_today,
                        color: Colors.purple,
                      ),
                      _StatCard(
                        label: 'Total Revenue',
                        value: '₹${analytics.totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Additional Metrics
                  Text(
                    'Key Metrics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _MetricRow(
                          label: 'Avg Charger Rating',
                          value: analytics.avgChargerRating != null
                              ? '${analytics.avgChargerRating!.toStringAsFixed(2)}/5.0'
                              : 'N/A',
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                        const Divider(),
                        _MetricRow(
                          label: 'Inactive Chargers',
                          value: '${analytics.inactiveChargers}',
                          icon: Icons.warning,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Quick Actions
                  Text(
                    'Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _AdminActionButton(
                    title: 'Manage Users',
                    subtitle: 'View and manage user accounts',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminUsersPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionButton(
                    title: 'Manage Chargers',
                    subtitle: 'Approve and manage charger listings',
                    icon: Icons.ev_station,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminChargersPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionButton(
                    title: 'Revenue Analytics',
                    subtitle: 'View detailed revenue reports',
                    icon: Icons.analytics,
                    onTap: () {
                      // Navigate to revenue analytics page
                    },
                  ),
                  const SizedBox(height: 12),
                  _AdminActionButton(
                    title: 'Fraud Management',
                    subtitle: 'Review and resolve fraud cases',
                    icon: Icons.security,
                    onTap: () {
                      // Navigate to fraud cases page
                    },
                  ),
                ],
              ),
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages to be implemented
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: const Center(child: Text('Users management page')),
    );
  }
}

class AdminChargersPage extends StatelessWidget {
  const AdminChargersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Chargers')),
      body: const Center(child: Text('Chargers management page')),
    );
  }
}
