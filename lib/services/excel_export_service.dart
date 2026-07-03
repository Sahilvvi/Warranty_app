import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ExcelExportService {
  static Future<File> generateWarrantyExcel({
    required Map<String, dynamic> reportData,
  }) async {
    final excel = Excel.createExcel();

    // Summary Sheet
    final summarySheet = excel['Summary'];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};
    _addSummarySheet(summarySheet, summary);

    // Warranties Sheet
    final warrantySheet = excel['Warranties'];
    final warranties = (reportData['warranties'] as List?) ?? [];
    _addWarrantySheet(warrantySheet, warranties);

    // Remove default sheet
    excel.delete('Sheet1');

    return _saveExcel(excel, 'warranty_report');
  }

  static Future<File> generateStockExcel({
    required Map<String, dynamic> reportData,
  }) async {
    final excel = Excel.createExcel();

    final summarySheet = excel['Summary'];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};
    _addSummarySheet(summarySheet, summary);

    final stockSheet = excel['Stock'];
    final stocks = (reportData['stocks'] as List?) ?? [];
    _addStockSheet(stockSheet, stocks);

    excel.delete('Sheet1');
    return _saveExcel(excel, 'stock_report');
  }

  static Future<File> generateProductExcel({
    required Map<String, dynamic> reportData,
  }) async {
    final excel = Excel.createExcel();

    final summarySheet = excel['Summary'];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};
    _addSummarySheet(summarySheet, summary);

    final productSheet = excel['Products'];
    final products = (reportData['products'] as List?) ?? [];
    _addProductSheet(productSheet, products);

    excel.delete('Sheet1');
    return _saveExcel(excel, 'product_report');
  }

  static Future<File> generateFullExcel({
    required Map<String, dynamic> reportData,
  }) async {
    final excel = Excel.createExcel();

    final summarySheet = excel['Summary'];
    final summary = reportData['summary'] as Map<String, dynamic>? ?? {};
    _addSummarySheet(summarySheet, summary);

    final warrantySheet = excel['Warranties'];
    final warranties = (reportData['warranties'] as List?) ?? [];
    _addWarrantySheet(warrantySheet, warranties);

    final productSheet = excel['Products'];
    final products = (reportData['products'] as List?) ?? [];
    _addProductSheet(productSheet, products);

    final stockSheet = excel['Stock'];
    final stocks = (reportData['stocks'] as List?) ?? [];
    _addStockSheet(stockSheet, stocks);

    excel.delete('Sheet1');
    return _saveExcel(excel, 'full_report');
  }

  static void _addSummarySheet(Sheet sheet, Map<String, dynamic> summary) {
    // Title
    sheet.appendRow([TextCellValue('Warranty Management System - Report Summary')]);
    sheet.appendRow([TextCellValue('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    // Headers
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#3F51B5'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    sheet.appendRow([TextCellValue('Metric'), TextCellValue('Value')]);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3)).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3)).cellStyle = headerStyle;

    // Data
    sheet.appendRow([TextCellValue('Total Products'), IntCellValue(summary['totalProducts'] ?? 0)]);
    sheet.appendRow([TextCellValue('Total Warranties'), IntCellValue(summary['totalWarranties'] ?? 0)]);
    sheet.appendRow([TextCellValue('Active Warranties'), IntCellValue(summary['activeWarranties'] ?? 0)]);
    sheet.appendRow([TextCellValue('Expiring Soon'), IntCellValue(summary['expiringSoonWarranties'] ?? 0)]);
    sheet.appendRow([TextCellValue('Expired Warranties'), IntCellValue(summary['expiredWarranties'] ?? 0)]);
    sheet.appendRow([TextCellValue('Total Consumers'), IntCellValue(summary['totalConsumers'] ?? 0)]);

    // Set column width
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 15);
  }

  static void _addWarrantySheet(Sheet sheet, List warranties) {
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#3F51B5'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = ['S.No', 'Product', 'Model', 'Serial Number', 'Dealer', 'Bill No',
      'Qty', 'Vendor', 'Period', 'Type', 'Start Date', 'End Date', 'Status', 'Consumer', 'Mobile'];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Apply header style
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    // Data rows
    for (int i = 0; i < warranties.length; i++) {
      final w = warranties[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(w['productName'] ?? ''),
        TextCellValue(w['model'] ?? ''),
        TextCellValue(w['serialNumber'] ?? ''),
        TextCellValue(w['dealerName'] ?? ''),
        TextCellValue(w['billNumber'] ?? ''),
        IntCellValue(w['quantity'] ?? 0),
        TextCellValue(w['vendor'] ?? 'N/A'),
        TextCellValue(w['warrantyPeriod'] ?? ''),
        TextCellValue(w['warrantyType'] ?? ''),
        TextCellValue(_formatDate(w['warrantyStartDate'])),
        TextCellValue(_formatDate(w['warrantyEndDate'])),
        TextCellValue(w['status'] ?? ''),
        TextCellValue(w['consumerName'] ?? 'N/A'),
        TextCellValue(w['consumerMobile'] ?? 'N/A'),
      ]);
    }

    // Set column widths
    final widths = [5.0, 18.0, 12.0, 18.0, 15.0, 12.0, 5.0, 12.0, 10.0, 10.0, 12.0, 12.0, 10.0, 15.0, 12.0];
    for (int i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
  }

  static void _addProductSheet(Sheet sheet, List products) {
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#3F51B5'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = ['S.No', 'Product Name', 'Model', 'Category', 'Active Warranties',
      'Expiring Soon', 'Expired', 'Status'];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    for (int i = 0; i < products.length; i++) {
      final p = products[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(p['name'] ?? ''),
        TextCellValue(p['model'] ?? ''),
        TextCellValue(p['category'] ?? 'N/A'),
        IntCellValue(p['activeWarranties'] ?? 0),
        IntCellValue(p['expiringSoonWarranties'] ?? 0),
        IntCellValue(p['expiredWarranties'] ?? 0),
        TextCellValue((p['isActive'] ?? true) ? 'Active' : 'Inactive'),
      ]);
    }

    final widths = [5.0, 20.0, 15.0, 15.0, 15.0, 12.0, 10.0, 10.0];
    for (int i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
  }

  static void _addStockSheet(Sheet sheet, List stocks) {
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#3F51B5'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );

    final headers = ['S.No', 'Level', 'Product', 'Owner/Name', 'Quantity', 'Batch/Invoice', 'Date'];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerStyle;
    }

    for (int i = 0; i < stocks.length; i++) {
      final s = stocks[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(s['level'] ?? ''),
        TextCellValue(s['productName'] ?? ''),
        TextCellValue(s['ownerName'] ?? 'N/A'),
        IntCellValue(s['quantity'] ?? 0),
        TextCellValue(s['batchNumber'] ?? s['invoiceNo'] ?? 'N/A'),
        TextCellValue(_formatDate(s['date'])),
      ]);
    }

    final widths = [5.0, 12.0, 18.0, 15.0, 10.0, 15.0, 12.0];
    for (int i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }
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

  static Future<File> _saveExcel(Excel excel, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/${fileName}_$timestamp.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }
}
