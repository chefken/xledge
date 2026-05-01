import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:xledge/models/expense_model.dart';
import 'package:xledge/models/void_analysis.dart';

class PdfService {
  PdfService._();

  static Future<void> generateMonthlyReport({
    required int month,
    required int year,
    required List<Expense> expenses,
    required VoidAnalysis analysis,
    required double totalAllowance,
  }) async {
    final pdf  = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();

    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final spendOnly = expenses.where((e) => !e.isAllowance).toList();
    final allowList = expenses.where((e) => e.isAllowance).toList();
    final net       = totalAllowance - analysis.totalSpend;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'XLedge',
                style: pw.TextStyle(font: bold, fontSize: 28,
                    color: PdfColor.fromHex('#1A73E8')),
              ),
              pw.Text(
                '${months[month]} $year',
                style: pw.TextStyle(font: font, fontSize: 14,
                    color: PdfColor.fromHex('#5F6368')),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text('Monthly Financial Report',
              style: pw.TextStyle(font: font, fontSize: 12,
                  color: PdfColor.fromHex('#9AA0A6'))),
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColor.fromHex('#DADCE0')),
          pw.SizedBox(height: 16),
          pw.Row(children: [
            _summaryBox(bold, font, 'Total Spent',
                '₹${analysis.totalSpend.toStringAsFixed(2)}',
                PdfColor.fromHex('#D93025'), PdfColor.fromHex('#FCE8E6')),
            pw.SizedBox(width: 12),
            _summaryBox(bold, font, 'Allowance Received',
                '₹${totalAllowance.toStringAsFixed(2)}',
                PdfColor.fromHex('#1E8E3E'), PdfColor.fromHex('#E6F4EA')),
            pw.SizedBox(width: 12),
            _summaryBox(bold, font, 'Net Balance',
                '${net >= 0 ? '+' : ''}₹${net.toStringAsFixed(2)}',
                net >= 0
                    ? PdfColor.fromHex('#1E8E3E')
                    : PdfColor.fromHex('#D93025'),
                PdfColor.fromHex('#F8F9FA')),
          ]),
          pw.SizedBox(height: 24),
          if (analysis.categoryBreakdown.isNotEmpty) ...[
            pw.Text('Spending by Category',
                style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#DADCE0'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F3F4')),
                  children: [
                    _cell(bold, 'Category', isHeader: true),
                    _cell(bold, 'Amount', isHeader: true),
                    _cell(bold, 'Share', isHeader: true),
                  ],
                ),
                ...analysis.categoryBreakdown.map((c) => pw.TableRow(
                  children: [
                    _cell(font, c.category),
                    _cell(font, '₹${c.total.toStringAsFixed(2)}'),
                    _cell(font, '${c.percentage.toStringAsFixed(1)}%'),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 24),
          ],
          if (spendOnly.isNotEmpty) ...[
            pw.Text('Expense Transactions',
                style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#DADCE0'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F3F4')),
                  children: [
                    _cell(bold, 'Item', isHeader: true),
                    _cell(bold, 'Category', isHeader: true),
                    _cell(bold, 'Date', isHeader: true),
                    _cell(bold, 'Amount', isHeader: true),
                  ],
                ),
                ...spendOnly.map((e) => pw.TableRow(
                  children: [
                    _cell(font, e.title),
                    _cell(font, e.category),
                    _cell(font, _fmtDate(e.date)),
                    _cell(font, '-₹${e.amount.toStringAsFixed(2)}'),
                  ],
                )),
              ],
            ),
            pw.SizedBox(height: 24),
          ],
          if (allowList.isNotEmpty) ...[
            pw.Text('Allowance Received',
                style: pw.TextStyle(font: bold, fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#DADCE0'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F1F3F4')),
                  children: [
                    _cell(bold, 'Description', isHeader: true),
                    _cell(bold, 'Date', isHeader: true),
                    _cell(bold, 'Amount', isHeader: true),
                  ],
                ),
                ...allowList.map((e) => pw.TableRow(
                  children: [
                    _cell(font, e.title),
                    _cell(font, _fmtDate(e.date)),
                    _cell(font, '+₹${e.amount.toStringAsFixed(2)}'),
                  ],
                )),
              ],
            ),
          ],
          pw.SizedBox(height: 32),
          pw.Divider(color: PdfColor.fromHex('#DADCE0')),
          pw.SizedBox(height: 8),
          pw.Text('Generated by XLedge · ${_fmtDate(DateTime.now())}',
              style: pw.TextStyle(font: font, fontSize: 9,
                  color: PdfColor.fromHex('#9AA0A6'))),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'XLedge_${months[month]}_$year.pdf',
    );
  }

  static pw.Widget _summaryBox(pw.Font bold, pw.Font font, String label,
      String value, PdfColor color, PdfColor bg) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bg,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(font: font, fontSize: 9,
                    color: PdfColor.fromHex('#5F6368'))),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(font: bold, fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cell(pw.Font font, String text,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text,
          style: pw.TextStyle(
            font: font,
            fontSize: isHeader ? 10 : 9,
            color: isHeader
                ? PdfColor.fromHex('#202124')
                : PdfColor.fromHex('#5F6368'),
          )),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}