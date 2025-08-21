import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReportService {
  static Future<void> exportToCsv(List<Map<String, dynamic>> data) async {
    final List<List<dynamic>> rows = [
      ['Category', 'Amount', 'Date'], // Header
      ...data.map((expense) => [
            expense['category'],
            expense['amount'],
            expense['date'],
          ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles(
      [XFile(path)],
      subject: 'Expense Report',
    );
  }

  static Future<void> exportToPdf(
    List<Map<String, dynamic>> categoryData,
    List<Map<String, dynamic>> trendData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Expense Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Category Distribution')),
              pw.SizedBox(height: 10),
              _buildPdfCategoryTable(categoryData),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Spending Trends')),
              pw.SizedBox(height: 10),
              _buildPdfTrendTable(trendData),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(path)],
      subject: 'Expense Report',
    );
  }

  static pw.Widget _buildPdfCategoryTable(List<Map<String, dynamic>> data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Category', 'Amount', 'Percentage'],
      data: data.map((item) {
        final total = data.fold(0.0, (sum, e) => sum + (e['amount'] as double));
        final percentage = (item['amount'] as double) / total * 100;
        return [
          item['category'],
          '₹${item['amount'].toStringAsFixed(2)}',
          '${percentage.toStringAsFixed(1)}%',
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      ),
      cellAlignment: pw.Alignment.center,
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  static pw.Widget _buildPdfTrendTable(List<Map<String, dynamic>> data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Day', 'Amount'],
      data: data.map((item) => [
        item['day'],
        '₹${item['amount'].toStringAsFixed(2)}',
      ]).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
      ),
      cellAlignment: pw.Alignment.center,
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }
}
