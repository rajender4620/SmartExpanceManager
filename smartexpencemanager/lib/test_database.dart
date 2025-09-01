import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'models/expense.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _connectionStatus = 'Testing...';
  List<String> _testResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
  }

  Future<void> _testDatabaseConnection() async {
    List<String> results = [];
    
    try {
      // Test 1: Check database initialization
      results.add('✅ Database service initialized');
      
      // Test 2: Get database instance
      final db = await _databaseService.database;
      results.add('✅ Database instance created');
      results.add('📁 Database path: ${db.path}');
      
      // Test 3: Check if table exists
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      results.add('✅ Tables found: ${tables.map((t) => t['name']).join(', ')}');
      
      // Test 4: Get all expenses
      final expenses = await _databaseService.getAllExpenses();
      results.add('✅ Retrieved ${expenses.length} expenses from database');
      
      // Test 5: Get total expenses
      final total = await _databaseService.getTotalExpenses();
      results.add('✅ Total expenses calculated: ₹${total.toStringAsFixed(2)}');
      
      // Test 6: Get category totals
      final categoryTotals = await _databaseService.getTotalExpensesByCategory();
      results.add('✅ Category breakdown: ${categoryTotals.keys.length} categories');
      
      // Test 7: Insert a test expense
      final testExpense = Expense(
        title: 'Database Test Expense',
        amount: 1.0,
        category: 'Other',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final testId = await _databaseService.insertExpense(testExpense);
      results.add('✅ Test expense inserted with ID: $testId');
      
      // Test 8: Update the test expense
      final updatedExpense = testExpense.copyWith(
        id: testId,
        title: 'Updated Test Expense',
        amount: 2.0,
      );
      await _databaseService.updateExpense(updatedExpense);
      results.add('✅ Test expense updated successfully');
      
      // Test 9: Retrieve the updated expense
      final retrievedExpense = await _databaseService.getExpenseById(testId);
      if (retrievedExpense != null && retrievedExpense.title == 'Updated Test Expense') {
        results.add('✅ Test expense retrieved and verified');
      } else {
        results.add('❌ Test expense retrieval failed');
      }
      
      // Test 10: Delete the test expense
      await _databaseService.deleteExpense(testId);
      final deletedExpense = await _databaseService.getExpenseById(testId);
      if (deletedExpense == null) {
        results.add('✅ Test expense deleted successfully');
      } else {
        results.add('❌ Test expense deletion failed');
      }
      
      setState(() {
        _connectionStatus = 'Database Connection: ✅ WORKING';
        _testResults = results;
        _isLoading = false;
      });
      
    } catch (e) {
      results.add('❌ Database error: $e');
      setState(() {
        _connectionStatus = 'Database Connection: ❌ FAILED';
        _testResults = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database Connection Test',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectionStatus,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _connectionStatus.contains('WORKING') 
                            ? Colors.green 
                            : _connectionStatus.contains('FAILED')
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test Results:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    final result = _testResults[index];
                    final isSuccess = result.startsWith('✅');
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isSuccess ? Icons.check_circle : Icons.error,
                            color: isSuccess ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.substring(2), // Remove emoji
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isSuccess ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isLoading = true;
                    _testResults.clear();
                    _connectionStatus = 'Testing...';
                  });
                  _testDatabaseConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Retest Connection',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
