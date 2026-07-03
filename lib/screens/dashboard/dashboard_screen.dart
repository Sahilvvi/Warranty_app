import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchDashboard(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final dashboard = provider.dashboard;
        if (dashboard == null) {
          return const Center(child: Text('No data available'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context, dashboard),
                const SizedBox(height: 24),
                _buildStockSection(context, dashboard),
                const SizedBox(height: 24),
                _buildWarrantyByProduct(context, dashboard),
                const SizedBox(height: 24),
                _buildRecentWarranties(context, dashboard),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('Total Warranties', dashboard.totalWarranties.toString(),
                Icons.verified, Colors.blue),
            _buildStatCard('Active', dashboard.activeWarranties.toString(),
                Icons.check_circle, Colors.green),
            _buildStatCard('Expiring Soon', dashboard.expiringSoonWarranties.toString(),
                Icons.warning, Colors.orange),
            _buildStatCard('Expired', dashboard.expiredWarranties.toString(),
                Icons.cancel, Colors.red),
            _buildStatCard('Products', dashboard.totalProducts.toString(),
                Icons.category, Colors.purple),
            _buildStatCard('Consumers', dashboard.totalConsumers.toString(),
                Icons.people, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSection(BuildContext context, DashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStockCard('Manufacturer', dashboard.totalManufacturerStock, Colors.indigo),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStockCard('Distributor', dashboard.totalDistributorStock, Colors.amber[800]!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStockCard('Dealer', dashboard.totalDealerStock, Colors.teal),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockCard(String title, int value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildWarrantyByProduct(BuildContext context, DashboardData dashboard) {
    if (dashboard.warrantiesByProduct.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warranties by Product',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dashboard.warrantiesByProduct.map((item) => Card(
              child: ListTile(
                title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    _buildBadge('Active: ${item.active}', Colors.green),
                    const SizedBox(width: 8),
                    _buildBadge('Soon: ${item.expiringSoon}', Colors.orange),
                    const SizedBox(width: 8),
                    _buildBadge('Expired: ${item.expired}', Colors.red),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildRecentWarranties(BuildContext context, DashboardData dashboard) {
    if (dashboard.recentWarranties.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Warranties',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dashboard.recentWarranties.map((w) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(w.status).withOpacity(0.2),
                  child: Icon(Icons.verified, color: _getStatusColor(w.status), size: 20),
                ),
                title: Text(w.productName),
                subtitle: Text('SN: ${w.serialNumber} • ${w.dealerName}'),
                trailing: _buildStatusChip(w.status),
              ),
            )),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'expiresoon':
      case 'expire soon':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
