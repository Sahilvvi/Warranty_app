import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import '../../services/api_service.dart';
import '../../services/pdf_export_service.dart';
import '../../services/excel_export_service.dart';
import '../../config/api_config.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isExporting = false;
  String _exportingType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Export', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3F51B5),
                    const Color(0xFF3F51B5).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3F51B5).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Export Reports',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Generate PDF or Excel reports',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Full Report Section
            _buildSectionTitle('Complete Report'),
            const SizedBox(height: 10),
            _buildReportCard(
              icon: Icons.summarize_rounded,
              title: 'Full Business Report',
              subtitle: 'All warranties, products & stock data',
              color: Colors.indigo,
              onPdf: () => _exportReport('full', 'pdf'),
              onExcel: () => _exportReport('full', 'excel'),
            ),
            const SizedBox(height: 20),

            // Individual Reports
            _buildSectionTitle('Individual Reports'),
            const SizedBox(height: 10),
            _buildReportCard(
              icon: Icons.verified_rounded,
              title: 'Warranty Report',
              subtitle: 'All warranty registrations with status',
              color: Colors.green,
              onPdf: () => _exportReport('warranty', 'pdf'),
              onExcel: () => _exportReport('warranty', 'excel'),
            ),
            const SizedBox(height: 10),
            _buildReportCard(
              icon: Icons.inventory_2_rounded,
              title: 'Stock Report',
              subtitle: 'Manufacturer → Distributor → Dealer stock',
              color: Colors.orange,
              onPdf: () => _exportReport('stock', 'pdf'),
              onExcel: () => _exportReport('stock', 'excel'),
            ),
            const SizedBox(height: 10),
            _buildReportCard(
              icon: Icons.category_rounded,
              title: 'Product Report',
              subtitle: 'All products with warranty statistics',
              color: Colors.purple,
              onPdf: () => _exportReport('product', 'pdf'),
              onExcel: () => _exportReport('product', 'excel'),
            ),
            const SizedBox(height: 20),

            // Filtered Reports
            _buildSectionTitle('Filtered Warranty Reports'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildFilterChipCard(
                    'Active',
                    Icons.check_circle,
                    Colors.green,
                    () => _exportReport('warranty_active', 'pdf'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChipCard(
                    'Expiring',
                    Icons.warning,
                    Colors.orange,
                    () => _exportReport('warranty_expiresoon', 'pdf'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChipCard(
                    'Expired',
                    Icons.cancel,
                    Colors.red,
                    () => _exportReport('warranty_expired', 'pdf'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onPdf,
    required VoidCallback onExcel,
  }) {
    final isThisExporting = _isExporting && _exportingType.contains(title.split(' ').first.toLowerCase());

    return Card(
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isThisExporting)
                    const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isExporting ? null : onPdf,
                      icon: const Icon(Icons.picture_as_pdf, size: 18, color: Colors.red),
                      label: const Text('PDF', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isExporting ? null : onExcel,
                      icon: const Icon(Icons.table_chart, size: 18, color: Colors.green),
                      label: const Text('Excel', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[700]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: _isExporting ? null : onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
              const SizedBox(height: 4),
              Text('PDF', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportReport(String type, String format) async {
    setState(() {
      _isExporting = true;
      _exportingType = type;
    });

    try {
      // Fetch report data from API
      String apiUrl;
      switch (type) {
        case 'full':
          apiUrl = ApiConfig.reportFull;
          break;
        case 'warranty':
          apiUrl = ApiConfig.reportWarranty;
          break;
        case 'warranty_active':
          apiUrl = ApiConfig.reportWarrantyByStatus('Active');
          break;
        case 'warranty_expiresoon':
          apiUrl = ApiConfig.reportWarrantyByStatus('ExpireSoon');
          break;
        case 'warranty_expired':
          apiUrl = ApiConfig.reportWarrantyByStatus('Expired');
          break;
        case 'stock':
          apiUrl = ApiConfig.reportStock;
          break;
        case 'product':
          apiUrl = ApiConfig.reportProduct;
          break;
        default:
          apiUrl = ApiConfig.reportFull;
      }

      final response = await ApiService.get(apiUrl);

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch report data');
      }

      final reportData = response['data'] as Map<String, dynamic>;
      File file;

      if (format == 'pdf') {
        file = await _generatePdf(type, reportData);
        // Show PDF preview and share
        if (mounted) {
          _showPdfPreviewAndShare(file);
        }
      } else {
        file = await _generateExcel(type, reportData);
        // Share Excel file
        if (mounted) {
          _shareFile(file, 'Excel report generated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
        _exportingType = '';
      });
    }
  }

  Future<File> _generatePdf(String type, Map<String, dynamic> data) async {
    switch (type) {
      case 'full':
        return PdfExportService.generateFullReport(reportData: data);
      case 'warranty':
      case 'warranty_active':
      case 'warranty_expiresoon':
      case 'warranty_expired':
        return PdfExportService.generateWarrantyReport(reportData: data);
      case 'stock':
        return PdfExportService.generateStockReport(reportData: data);
      case 'product':
        return PdfExportService.generateProductReport(reportData: data);
      default:
        return PdfExportService.generateFullReport(reportData: data);
    }
  }

  Future<File> _generateExcel(String type, Map<String, dynamic> data) async {
    switch (type) {
      case 'full':
        return ExcelExportService.generateFullExcel(reportData: data);
      case 'warranty':
        return ExcelExportService.generateWarrantyExcel(reportData: data);
      case 'stock':
        return ExcelExportService.generateStockExcel(reportData: data);
      case 'product':
        return ExcelExportService.generateProductExcel(reportData: data);
      default:
        return ExcelExportService.generateFullExcel(reportData: data);
    }
  }

  void _showPdfPreviewAndShare(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Report Preview'),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Color(0xFF3F51B5)),
                onPressed: () => _shareFile(file, 'PDF report ready to share!'),
                tooltip: 'Share',
              ),
              IconButton(
                icon: const Icon(Icons.print_rounded, color: Color(0xFF3F51B5)),
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (_) => file.readAsBytesSync(),
                  );
                },
                tooltip: 'Print',
              ),
            ],
          ),
          body: PdfPreview(
            build: (_) => file.readAsBytesSync(),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
          ),
        ),
      ),
    );
  }

  void _shareFile(File file, String message) {
    Share.shareXFiles(
      [XFile(file.path)],
      text: 'Warranty Management Report',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
