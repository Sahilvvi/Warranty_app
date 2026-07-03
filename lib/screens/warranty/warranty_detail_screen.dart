import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/warranty_model.dart';
import '../../config/api_config.dart';

class WarrantyDetailScreen extends StatelessWidget {
  final WarrantyRegistration warranty;

  const WarrantyDetailScreen({super.key, required this.warranty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warranty Details'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 20),
            _buildSection(context, 'Product Information', [
              _buildDetailRow('Product', warranty.productName),
              _buildDetailRow('Model', warranty.model),
              _buildDetailRow('Serial Number', warranty.serialNumber),
              _buildDetailRow('Manufactured Date',
                  DateFormat('dd MMM yyyy').format(warranty.manufacturedDate)),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Warranty Information', [
              _buildDetailRow('Warranty Period', warranty.warrantyPeriod),
              _buildDetailRow('Warranty Type', warranty.warrantyType),
              _buildDetailRow('Start Date',
                  DateFormat('dd MMM yyyy').format(warranty.warrantyStartDate)),
              _buildDetailRow('End Date',
                  DateFormat('dd MMM yyyy').format(warranty.warrantyEndDate)),
              _buildDetailRow('Status', warranty.status),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, 'Purchase Details', [
              _buildDetailRow('Bill Number', warranty.billNumber),
              _buildDetailRow('Quantity', warranty.quantity.toString()),
              _buildDetailRow('Vendor', warranty.vendor ?? 'N/A'),
              _buildDetailRow('Dealer', warranty.dealerName),
            ]),
            if (warranty.consumer != null) ...[
              const SizedBox(height: 16),
              _buildSection(context, 'Consumer Details', [
                _buildDetailRow('Name', warranty.consumer!.name),
                _buildDetailRow('Mobile', warranty.consumer!.mobileNumber),
              ]),
            ],
            if (warranty.photoUrl != null) ...[
              const SizedBox(height: 16),
              Text(
                'Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${ApiConfig.baseUrl}${warranty.photoUrl}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (warranty.status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'expiresoon':
      case 'expire soon':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case 'expired':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    warranty.productName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${warranty.status}',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
