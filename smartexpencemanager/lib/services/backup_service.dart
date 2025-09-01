import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

enum BackupFormat {
  json,
  csv,
  database,
}

class BackupService {
  static final DatabaseService _databaseService = DatabaseService();

  /// Export all expense data to JSON format
  static Future<File> exportToJson() async {
    try {
      final expenses = await _databaseService.getAllExpenses();
      final categoryTotals = await _databaseService.getTotalExpensesByCategory();
      
      final exportData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'expenses': expenses.map((expense) => expense.toMap()).toList(),
        'categoryTotals': categoryTotals,
        'metadata': {
          'totalExpenses': categoryTotals.values.fold(0.0, (sum, value) => sum + value),
          'recordCount': expenses.length,
          'appVersion': '1.0.0',
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'expense_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      return file;
    } catch (e) {
      throw BackupException('Failed to export JSON: $e');
    }
  }

  /// Export all expense data to CSV format
  static Future<File> exportToCsv() async {
    try {
      final expenses = await _databaseService.getAllExpenses();
      
      final csvContent = StringBuffer();
      // CSV Header
      csvContent.writeln('ID,Title,Category,Amount,Date,Description,CreatedAt,UpdatedAt');
      
      // CSV Data
      for (final expense in expenses) {
        csvContent.writeln([
          expense.id ?? '',
          _escapeCsvField(expense.title),
          _escapeCsvField(expense.category),
          expense.amount.toString(),
          expense.date.toIso8601String().split('T')[0],
          _escapeCsvField(expense.description ?? ''),
          expense.createdAt.toIso8601String(),
          expense.updatedAt.toIso8601String(),
        ].join(','));
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'expenses_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvContent.toString());
      return file;
    } catch (e) {
      throw BackupException('Failed to export CSV: $e');
    }
  }

  /// Export complete SQLite database file
  static Future<File> exportDatabase() async {
    try {
      final databasePath = await _databaseService.database;
      final dbFile = File(databasePath.path);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'expense_database_${DateTime.now().millisecondsSinceEpoch}.db';
      final backupFile = File('${directory.path}/$fileName');
      
      await dbFile.copy(backupFile.path);
      return backupFile;
    } catch (e) {
      throw BackupException('Failed to export database: $e');
    }
  }

  /// Import expenses from JSON file
  static Future<ImportResult> importFromJson(File jsonFile) async {
    try {
      final jsonString = await jsonFile.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate JSON structure
      if (!jsonData.containsKey('expenses') || !jsonData.containsKey('version')) {
        throw BackupException('Invalid backup file format');
      }

      final expensesList = jsonData['expenses'] as List<dynamic>;
      final expenses = expensesList
          .map((expenseMap) => Expense.fromMap(expenseMap as Map<String, dynamic>))
          .toList();

      int imported = 0;
      int skipped = 0;
      int errors = 0;

      for (final expense in expenses) {
        try {
          // Check if expense already exists
          final existing = await _databaseService.getExpenseById(expense.id ?? '');
          if (existing == null) {
            await _databaseService.insertExpense(expense);
            imported++;
          } else {
            skipped++;
          }
        } catch (e) {
          errors++;
        }
      }

      return ImportResult(
        totalRecords: expenses.length,
        imported: imported,
        skipped: skipped,
        errors: errors,
      );
    } catch (e) {
      throw BackupException('Failed to import JSON: $e');
    }
  }

  /// Share backup file with other apps
  static Future<void> shareBackup(File backupFile, BackupFormat format) async {
    String subject;
    String text;

    switch (format) {
      case BackupFormat.json:
        subject = 'SmartExpense - Complete Backup (JSON)';
        text = 'Your complete expense data backup in JSON format.';
        break;
      case BackupFormat.csv:
        subject = 'SmartExpense - Data Export (CSV)';
        text = 'Your expense data exported as CSV for spreadsheet applications.';
        break;
      case BackupFormat.database:
        subject = 'SmartExpense - Database Backup';
        text = 'Complete SQLite database backup file.';
        break;
    }

    await Share.shareXFiles(
      [XFile(backupFile.path)],
      subject: subject,
      text: text,
    );
  }

  /// Create automatic backup (could be scheduled)
  static Future<BackupInfo> createAutomaticBackup() async {
    try {
      final jsonFile = await exportToJson();
      final fileSize = await jsonFile.length();
      
      return BackupInfo(
        filePath: jsonFile.path,
        format: BackupFormat.json,
        createdAt: DateTime.now(),
        fileSize: fileSize,
        recordCount: (await _databaseService.getAllExpenses()).length,
      );
    } catch (e) {
      throw BackupException('Failed to create automatic backup: $e');
    }
  }

  /// Validate backup file integrity
  static Future<bool> validateBackup(File backupFile, BackupFormat format) async {
    try {
      switch (format) {
        case BackupFormat.json:
          final content = await backupFile.readAsString();
          final jsonData = jsonDecode(content);
          return jsonData is Map<String, dynamic> && 
                 jsonData.containsKey('expenses') && 
                 jsonData.containsKey('version');
        
        case BackupFormat.csv:
          final content = await backupFile.readAsString();
          return content.isNotEmpty && content.contains('Title,Category,Amount');
        
        case BackupFormat.database:
          // Basic file existence and size check
          return await backupFile.exists() && await backupFile.length() > 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Helper method to escape CSV fields
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

/// Backup operation result
class BackupInfo {
  final String filePath;
  final BackupFormat format;
  final DateTime createdAt;
  final int fileSize;
  final int recordCount;

  const BackupInfo({
    required this.filePath,
    required this.format,
    required this.createdAt,
    required this.fileSize,
    required this.recordCount,
  });
}

/// Import operation result
class ImportResult {
  final int totalRecords;
  final int imported;
  final int skipped;
  final int errors;

  const ImportResult({
    required this.totalRecords,
    required this.imported,
    required this.skipped,
    required this.errors,
  });

  bool get hasErrors => errors > 0;
  bool get isSuccessful => imported > 0 && errors == 0;
  
  String get summary => 
      'Imported: $imported, Skipped: $skipped, Errors: $errors';
}

/// Custom exception for backup operations
class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  
  @override
  String toString() => 'BackupException: $message';
}
