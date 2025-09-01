import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Expense> _allExpenses = [];
  bool _isLoading = true;
  String _databasePath = '';
  String _selectedView = 'expenses';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Get database path
      final db = await _databaseService.database;
      _databasePath = db.path;
      print('Database path: $_databasePath');

      // Load all expenses
      final expenses = await _databaseService.getAllExpenses();

      setState(() {
        _allExpenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Clear All Data',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete ALL expenses? This action cannot be undone.',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(
                  'Delete All',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.clearAllData();
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error clearing data: $e')));
        }
      }
    }
  }

  void _copyDatabasePath() {
    Clipboard.setData(ClipboardData(text: _databasePath));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Database path copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database Viewer',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllData();
              } else if (value == 'path') {
                _copyDatabasePath();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'path',
                    child: Row(
                      children: [
                        const Icon(Icons.copy, size: 20),
                        const SizedBox(width: 8),
                        Text('Copy DB Path', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_forever,
                          size: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Clear All Data',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildInfoCards(),
                  _buildViewSelector(),
                  Expanded(child: _buildSelectedView()),
                ],
              ),
    );
  }

  Widget _buildInfoCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Expenses',
                  '${_allExpenses.length}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Total Amount',
                  '₹${_allExpenses.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                  Icons.currency_rupee,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage, color: Colors.orange),
              title: Text(
                'Database Path',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _databasePath,
                style: GoogleFonts.poppins(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: _copyDatabasePath,
                tooltip: 'Copy path',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expenses',
                  label: Text('All Expenses'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: 'raw',
                  label: Text('Raw Data'),
                  icon: Icon(Icons.code),
                ),
              ],
              selected: {_selectedView},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedView = selection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'expenses':
        return _buildExpensesList();
      case 'raw':
        return _buildRawDataView();
      default:
        return _buildExpensesList();
    }
  }

  Widget _buildExpensesList() {
    if (_allExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses found',
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some expenses to see them here',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allExpenses.length,
      itemBuilder: (context, index) {
        final expense = _allExpenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              expense.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '₹${expense.amount.toStringAsFixed(2)} • ${expense.category}',
              style: GoogleFonts.poppins(),
            ),
            trailing: Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('ID', expense.id ?? 'N/A'),
                    _buildDetailRow('Title', expense.title),
                    _buildDetailRow(
                      'Amount',
                      '₹${expense.amount.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow('Category', expense.category),
                    _buildDetailRow(
                      'Date',
                      DateFormat('MMM dd, yyyy HH:mm').format(expense.date),
                    ),
                    _buildDetailRow(
                      'Description',
                      expense.description ?? 'No description',
                    ),
                    _buildDetailRow(
                      'Created',
                      DateFormat(
                        'MMM dd, yyyy HH:mm:ss',
                      ).format(expense.createdAt),
                    ),
                    _buildDetailRow(
                      'Updated',
                      DateFormat(
                        'MMM dd, yyyy HH:mm:ss',
                      ).format(expense.updatedAt),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.poppins())),
        ],
      ),
    );
  }

  Widget _buildRawDataView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: SelectableText(
              _allExpenses.isEmpty
                  ? 'No data available'
                  : _allExpenses
                      .map((expense) {
                        return '''
ID: ${expense.id}
Title: ${expense.title}
Amount: ${expense.amount}
Category: ${expense.category}
Date: ${expense.date.toIso8601String()}
Description: ${expense.description ?? 'null'}
Created: ${expense.createdAt.toIso8601String()}
Updated: ${expense.updatedAt.toIso8601String()}
-------------------''';
                      })
                      .join('\n'),
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }
}
