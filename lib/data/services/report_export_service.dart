import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/models/report_models.dart';

class ReportExportService {
  static final DateFormat _timestampFormat = DateFormat('yyyyMMdd_HHmmss');
  static final DateFormat _generatedFormat = DateFormat('dd MMM yyyy, h:mm a');

  Future<File> exportCsv({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final file = await _createFile(title, 'csv');
    final csvContent = csv.encode([
      headers,
      ...rows,
    ]);
    await file.writeAsString(csvContent);
    await _shareFile(file, title);
    return file;
  }

  Future<File> exportPdf({
    required String title,
    required List<String> summaryLines,
    required List<String> headers,
    required List<List<String>> rows,
    String? period,
    List<VillaProfitReportItem>? villaProfitItems,
    List<RoomWiseProfitReportItem>? roomProfitItems,
  }) async {
    final file = await _createFile(title, 'pdf');
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          if (roomProfitItems != null) {
            return _buildRoomWiseProfitPdf(
              title: title,
              period: period,
              items: roomProfitItems,
            );
          }
          if (villaProfitItems != null) {
            return _buildVillaWiseProfitPdf(
              title: title,
              period: period,
              items: villaProfitItems,
            );
          }
          return _buildGenericPdf(
            title: title,
            summaryLines: summaryLines,
            headers: headers,
            rows: rows,
          );
        },
      ),
    );

    await file.writeAsBytes(await document.save());
    await _shareFile(file, title);
    return file;
  }

  List<pw.Widget> _buildGenericPdf({
    required String title,
    required List<String> summaryLines,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return [
      _header(title: title),
      pw.SizedBox(height: 12),
      ...summaryLines.map((line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(line),
          )),
      pw.SizedBox(height: 16),
      pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignment: pw.Alignment.centerLeft,
      ),
    ];
  }

  List<pw.Widget> _buildRoomWiseProfitPdf({
    required String title,
    required String? period,
    required List<RoomWiseProfitReportItem> items,
  }) {
    final grouped = <String, List<RoomWiseProfitReportItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.villaName, () => []).add(item);
    }

    final expectedRent = _sum(items, (item) => item.expectedRent);
    final collected = _sum(items, (item) => item.rentReceived);
    final pending = _sum(items, (item) => item.pendingRent);
    final expenses = _sum(items, (item) => item.totalExpenses);
    final profit = _sum(items, (item) => item.actualProfit);

    return [
      _header(title: title, period: period, generatedDate: DateTime.now()),
      pw.SizedBox(height: 14),
      _summaryGrid(
        title: 'Summary (QAR)',
        items: [
          _PdfMetric('Total Rooms', items.length.toString()),
          _PdfMetric(
            'Occupied Rooms',
            items.where((item) => item.isOccupied).length.toString(),
          ),
          _PdfMetric(
            'Vacant Rooms',
            items.where((item) => item.isVacant).length.toString(),
          ),
          _PdfMetric('Expected Rent', _amount(expectedRent)),
          _PdfMetric('Collected', _amount(collected)),
          _PdfMetric('Pending', _amount(pending)),
          _PdfMetric('Expenses', _amount(expenses)),
          _PdfMetric('Net Profit', _amount(profit)),
        ],
      ),
      pw.SizedBox(height: 16),
      ...grouped.entries.expand(
        (entry) => _villaRoomSection(entry.key, entry.value),
      ),
    ];
  }

  List<pw.Widget> _buildVillaWiseProfitPdf({
    required String title,
    required String? period,
    required List<VillaProfitReportItem> items,
  }) {
    final expectedRent = _sum(items, (item) => item.expectedRent);
    final collected = _sum(items, (item) => item.receivedIncome);
    final pending = _sum(items, (item) => item.pendingAmount);
    final expense = _sum(items, (item) => item.totalExpense);
    final profit = _sum(items, (item) => item.netProfit);

    return [
      _header(title: title, period: period, generatedDate: DateTime.now()),
      pw.SizedBox(height: 14),
      _summaryGrid(
        title: 'Summary Totals (QAR)',
        items: [
          _PdfMetric('Villas', items.length.toString()),
          _PdfMetric('Expected Rent', _amount(expectedRent)),
          _PdfMetric('Collected', _amount(collected)),
          _PdfMetric('Pending', _amount(pending)),
          _PdfMetric('Expense', _amount(expense)),
          _PdfMetric('Net Profit', _amount(profit)),
        ],
      ),
      pw.SizedBox(height: 16),
      pw.Text(
        'Villa-wise Profit (QAR)',
        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headers: const [
          'Villa',
          'Expected Rent',
          'Collected',
          'Pending',
          'Expense',
          'Net Profit',
        ],
        data: [
          ...items.map(
            (item) => [
              item.villaName,
              _amount(item.expectedRent),
              _amount(item.receivedIncome),
              _amount(item.pendingAmount),
              _amount(item.totalExpense),
              _amount(item.netProfit),
            ],
          ),
          [
            'Total',
            _amount(expectedRent),
            _amount(collected),
            _amount(pending),
            _amount(expense),
            _amount(profit),
          ],
        ],
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: const {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerRight,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
        },
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      ),
    ];
  }

  Iterable<pw.Widget> _villaRoomSection(
    String villaName,
    List<RoomWiseProfitReportItem> rooms,
  ) {
    final expectedRent = _sum(rooms, (item) => item.expectedRent);
    final collected = _sum(rooms, (item) => item.rentReceived);
    final pending = _sum(rooms, (item) => item.pendingRent);
    final expenses = _sum(rooms, (item) => item.totalExpenses);
    final profit = _sum(rooms, (item) => item.actualProfit);

    return [
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              villaName,
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...rooms.map(_roomProfitCard),
            pw.Divider(color: PdfColors.grey300),
            _amountRows(
              title: 'Villa Total (QAR)',
              rows: [
                _PdfMetric('Expected Rent', _amount(expectedRent)),
                _PdfMetric('Collected', _amount(collected)),
                _PdfMetric('Pending', _amount(pending)),
                _PdfMetric('Expenses', _amount(expenses)),
                _PdfMetric('Profit', _amount(profit)),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  pw.Widget _roomProfitCard(RoomWiseProfitReportItem item) {
    final title = [
      item.displayRoomName,
      if (item.tenantName.trim().isNotEmpty) item.tenantName.trim(),
    ].join(' - ');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(9),
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Text('Status: ${item.status}',
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 6),
          _amountRows(
            rows: [
              _PdfMetric('Expected Rent', _amount(item.expectedRent)),
              _PdfMetric('Collected', _amount(item.rentReceived)),
              _PdfMetric('Pending', _amount(item.pendingRent)),
              _PdfMetric('Expenses', _amount(item.totalExpenses)),
              _PdfMetric('Profit', _amount(item.actualProfit)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _header({
    required String title,
    String? period,
    DateTime? generatedDate,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        if (period != null) ...[
          pw.SizedBox(height: 5),
          pw.Text('Period: $period', style: const pw.TextStyle(fontSize: 10)),
        ],
        if (generatedDate != null) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            'Generated: ${_generatedFormat.format(generatedDate)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }

  pw.Widget _summaryGrid({
    required String title,
    required List<_PdfMetric> items,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 10,
            runSpacing: 8,
            children: items
                .map(
                  (item) => pw.SizedBox(
                    width: 118,
                    child: _metricBlock(item.label, item.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  pw.Widget _metricBlock(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _amountRows({
    String? title,
    required List<_PdfMetric> rows,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
        ],
        ...rows.map(
          (row) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(row.label,
                      style: const pw.TextStyle(fontSize: 9)),
                ),
                pw.Text(
                  row.value,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _sum<T>(Iterable<T> items, double Function(T item) selector) {
    return items.fold<double>(0, (sum, item) => sum + selector(item));
  }

  String _amount(double value) => CurrencyFormatter.formatAmount(value);

  Future<File> _createFile(String title, String extension) async {
    final directory = await getTemporaryDirectory();
    final timestamp = _timestampFormat.format(DateTime.now());
    final safeTitle = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+$'), '');

    return File(p.join(directory.path, '${safeTitle}_$timestamp.$extension'));
  }

  Future<void> _shareFile(File file, String title) async {
    await SharePlus.instance.share(
      ShareParams(
        text: title,
        files: [XFile(file.path)],
      ),
    );
  }
}

class _PdfMetric {
  final String label;
  final String value;

  const _PdfMetric(this.label, this.value);
}
