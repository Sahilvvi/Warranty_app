import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfExportService {
  static Future<File> generateWarrantyReport({
    required Map<String, dynamic> reportData,
  }) async {
    final pdf = pw.Document();
    final warranties = (reportData['warranties'] as List?) ?? [];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Warranty Management Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildWarrantyTable(warranties),
        ],
      ),
    );

    return _saveDocument(pdf, 'warranty_report');
  }

  static Future<File> generateStockReport({
    required Map<String, dynamic> reportData,
  }) async {
    final pdf = pw.Document();
    final stocks = (reportData['stocks'] as List?) ?? [];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Stock Management Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildStockTable(stocks),
        ],
      ),
    );

    return _saveDocument(pdf, 'stock_report');
  }

  static Future<File> generateProductReport({
    required Map<String, dynamic> reportData,
  }) async {
    final pdf = pw.Document();
    final products = (reportData['products'] as List?) ?? [];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Product Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildProductTable(products),
        ],
      ),
    );

    return _saveDocument(pdf, 'product_report');
  }

  static Future<File> generateFullReport({
    required Map<String, dynamic> reportData,
  }) async {
    final pdf = pw.Document();
    final warranties = (reportData['warranties'] as List?) ?? [];
    final products = (reportData['products'] as List?) ?? [];
    final stocks = (reportData['stocks'] as List?) ?? [];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader('Complete Business Report'),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(summary),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Warranty Registrations'),
          pw.SizedBox(height: 8),
          _buildWarrantyTable(warranties),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Products'),
          pw.SizedBox(height: 8),
          _buildProductTable(products),
          pw.SizedBox(height: 24),
          _buildSectionTitle('Stock Inventory'),
          pw.SizedBox(height: 8),
          _buildStockTable(stocks),
        ],
      ),
    );

    return _saveDocument(pdf, 'full_report');
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 2, color: PdfColors.indigo)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              pw.SizedBox(height: 4),
              pw.Text('Maruthi Motor Pump - Warranty Management System',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.Text('Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: PdfColors.grey400)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Warranty Management System', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(Map<String, dynamic> summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Warranties', '${summary['totalWarranties'] ?? 0}'),
          _buildSummaryItem('Active', '${summary['activeWarranties'] ?? 0}'),
          _buildSummaryItem('Expiring Soon', '${summary['expiringSoonWarranties'] ?? 0}'),
          _buildSummaryItem('Expired', '${summary['expiredWarranties'] ?? 0}'),
          _buildSummaryItem('Products', '${summary['totalProducts'] ?? 0}'),
          _buildSummaryItem('Consumers', '${summary['totalConsumers'] ?? 0}'),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.indigo,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
  }

  static pw.Widget _buildWarrantyTable(List warranties) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo700),
      cellStyle: const pw.TextStyle(fontSize: 7),
      cellPadding: const pw.EdgeInsets.all(4),
      headerPadding: const pw.EdgeInsets.all(5),
      headers: ['#', 'Product', 'Serial No', 'Dealer', 'Period', 'Start', 'End', 'Status'],
      data: warranties.asMap().entries.map((entry) {
        final w = entry.value;
        return [
          '${entry.key + 1}',
          '${w['productName'] ?? ''}',
          '${w['serialNumber'] ?? ''}',
          '${w['dealerName'] ?? ''}',
          '${w['warrantyPeriod'] ?? ''}',
          _formatDate(w['warrantyStartDate']),
          _formatDate(w['warrantyEndDate']),
          '${w['status'] ?? ''}',
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildProductTable(List products) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo700),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(4),
      headerPadding: const pw.EdgeInsets.all(5),
      headers: ['#', 'Product Name', 'Model', 'Category', 'Active', 'Expiring', 'Expired', 'Status'],
      data: products.asMap().entries.map((entry) {
        final p = entry.value;
        return [
          '${entry.key + 1}',
          '${p['name'] ?? ''}',
          '${p['model'] ?? ''}',
          '${p['category'] ?? 'N/A'}',
          '${p['activeWarranties'] ?? 0}',
          '${p['expiringSoonWarranties'] ?? 0}',
          '${p['expiredWarranties'] ?? 0}',
          (p['isActive'] ?? true) ? 'Active' : 'Inactive',
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildStockTable(List stocks) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo700),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.all(4),
      headerPadding: const pw.EdgeInsets.all(5),
      headers: ['#', 'Level', 'Product', 'Owner', 'Qty', 'Batch/Invoice', 'Date'],
      data: stocks.asMap().entries.map((entry) {
        final s = entry.value;
        return [
          '${entry.key + 1}',
          '${s['level'] ?? ''}',
          '${s['productName'] ?? ''}',
          '${s['ownerName'] ?? 'N/A'}',
          '${s['quantity'] ?? 0}',
          '${s['batchNumber'] ?? s['invoiceNo'] ?? 'N/A'}',
          _formatDate(s['date']),
        ];
      }).toList(),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final d = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return date.toString();
    }
  }

  static Future<File> _saveDocument(pw.Document pdf, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/${fileName}_$timestamp.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
