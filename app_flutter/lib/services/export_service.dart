// lib/services/export_service.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../core/utils/currency_formatter.dart';
import '../data/database/app_database.dart';
import '../domain/entities/entities.dart';

/// Service for exporting movements to CSV format and sharing files.
class ExportService {
  Future<String> exportMovementsToCsv(List<MovementEntity> movements) async {
    final List<List<dynamic>> rows = [
      [
        'Fecha',
        'Tipo',
        'Monto',
        'Categoría',
        'Comercio',
        'Método de Pago',
        'Nota'
      ],
    ];

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (final movement in movements) {
      rows.add([
        dateFormat.format(movement.date),
        movement.type == MovementType.expense ? 'Gasto' : 'Ingreso',
        CurrencyFormatter.formatNumber(
            movement.amount, AppDatabase.currentCurrency),
        '', // category name - need to fetch separately
        movement.merchant ?? '',
        movement.paymentMethod ?? '',
        movement.note ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/todoaldia_export_$timestamp.csv');
    await file.writeAsString(csv);

    return file.path;
  }

  Future<void> shareExport(String filePath) async {
    await Share.shareXFiles([XFile(filePath)],
        text: 'Exportación de TodoAlDía');
  }

  Future<String> exportAndShare(List<MovementEntity> movements) async {
    final path = await exportMovementsToCsv(movements);
    await shareExport(path);
    return path;
  }
}
