import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTimeRange = 'Week';
  final List<String> _timeRanges = ['Week', 'Month', 'Year'];

  // Sample data - Replace with actual data from your database
  final List<Map<String, dynamic>> _expenseData = [
    {
      'category': 'Food & Dining',
      'amount': 450.0,
      'color': const Color(0xFFFF9E80),
    },
    {'category': 'Travel', 'amount': 850.0, 'color': const Color(0xFF80DEEA)},
    {
      'category': 'Bills & Utilities',
      'amount': 320.0,
      'color': const Color(0xFFB39DDB),
    },
    {'category': 'Shopping', 'amount': 650.0, 'color': const Color(0xFFFFF59D)},
  ];

  final List<Map<String, dynamic>> _weeklyData = [
    {'day': 'Mon', 'amount': 120.0},
    {'day': 'Tue', 'amount': 80.0},
    {'day': 'Wed', 'amount': 150.0},
    {'day': 'Thu', 'amount': 90.0},
    {'day': 'Fri', 'amount': 200.0},
    {'day': 'Sat', 'amount': 180.0},
    {'day': 'Sun', 'amount': 100.0},
  ];

  double get _totalExpenses =>
      _expenseData.fold(0, (sum, item) => sum + (item['amount'] as double));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTimeRangeSelector(),
              const SizedBox(height: 24),
              _buildCategoryDistributionCard(),
              const SizedBox(height: 24),
              _buildSpendingTrendsCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              _timeRanges.map((range) {
                final isSelected = range == _selectedTimeRange;
                return InkWell(
                  onTap: () => setState(() => _selectedTimeRange = range),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      range,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Distribution',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections:
                      _expenseData.map((data) {
                        return PieChartSectionData(
                          value: data['amount'],
                          title:
                              '${((data['amount'] / _totalExpenses) * 100).toStringAsFixed(1)}%',
                          color: data['color'],
                          radius: 100,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 500),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children:
                  _expenseData.map((data) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: data['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['category'],
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingTrendsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Trends',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      _weeklyData
                          .map((e) => e['amount'])
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₹${_weeklyData[groupIndex]['amount'].toStringAsFixed(2)}',
                          GoogleFonts.poppins(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _weeklyData[value.toInt()]['day'],
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups:
                      _weeklyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value['amount'],
                              color: Theme.of(context).colorScheme.primary,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportToCsv,
                icon: const Icon(Icons.table_chart),
                label: Text('Export CSV', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportToPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text('Export PDF', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _previewReport,
            icon: const Icon(Icons.preview),
            label: Text('Preview Report', style: GoogleFonts.poppins()),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _exportToCsv() async {
    // TODO: Implement CSV export
  }

  void _exportToPdf() async {
    // TODO: Implement PDF export
  }

  void _previewReport() {
    // TODO: Implement report preview
  }
}
