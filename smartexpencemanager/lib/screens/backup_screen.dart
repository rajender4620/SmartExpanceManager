import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/backup_service.dart';
import '../services/cloud_sync_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  SyncStatus _syncStatus = SyncStatus.idle;
  SyncStats? _syncStats;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
    _listenToSyncStatus();
  }

  void _loadSyncStats() async {
    try {
      final stats = await CloudSyncService.getSyncStats();
      setState(() {
        _syncStats = stats;
      });
    } catch (e) {
      // Handle error silently for demo
    }
  }

  void _listenToSyncStatus() {
    CloudSyncService.syncStatusStream.listen((status) {
      setState(() {
        _syncStatus = status;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup & Sync',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCloudSyncSection(),
            const SizedBox(height: 24),
            _buildLocalBackupSection(),
            const SizedBox(height: 24),
            _buildDataManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudSyncSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_sync,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cloud Synchronization',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sync Status
            _buildSyncStatusCard(),
            const SizedBox(height: 16),
            
            // Sync Statistics
            if (_syncStats != null) _buildSyncStatsCard(),
            const SizedBox(height: 16),
            
            // Sync Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _syncStatus == SyncStatus.syncing ? null : _performSync,
                    icon: _syncStatus == SyncStatus.syncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      _syncStatus == SyncStatus.syncing ? 'Syncing...' : 'Sync Now',
                      style: GoogleFonts.poppins(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showSyncSettings,
                  icon: const Icon(Icons.settings),
                  label: Text('Settings', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_syncStatus) {
      case SyncStatus.idle:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_off;
        statusText = 'Ready to sync';
        break;
      case SyncStatus.syncing:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Synchronizing...';
        break;
      case SyncStatus.success:
        statusColor = Colors.green;
        statusIcon = Icons.cloud_done;
        statusText = 'Sync successful';
        break;
      case SyncStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.cloud_off;
        statusText = 'Sync failed';
        break;
      case SyncStatus.conflict:
        statusColor = Colors.amber;
        statusIcon = Icons.warning;
        statusText = 'Sync conflicts detected';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Local Records:', style: GoogleFonts.poppins()),
              Text('${_syncStats!.localRecords}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cloud Records:', style: GoogleFonts.poppins()),
              Text('${_syncStats!.cloudRecords}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Last Sync:', style: GoogleFonts.poppins()),
              Text(
                _formatLastSync(_syncStats!.lastSync),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalBackupSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.backup,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Local Backup',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Export your data to share or backup locally',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            // Export Options
            _buildExportOption(
              'JSON Export',
              'Complete backup with all data',
              Icons.data_object,
              () => _exportData(BackupFormat.json),
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              'CSV Export',
              'Spreadsheet-compatible format',
              Icons.table_chart,
              () => _exportData(BackupFormat.csv),
            ),
            const SizedBox(height: 8),
            _buildExportOption(
              'Database Export',
              'Complete SQLite database file',
              Icons.storage,
              () => _exportData(BackupFormat.database),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildDataManagementSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.data_usage,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Management',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.blue),
              title: Text('Import Data', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Import expenses from backup file', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _importData,
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: Text('Restore from Cloud', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Restore data from cloud backup', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _restoreFromCloud,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: Text('Clear Local Data', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Delete all local expenses', style: GoogleFonts.poppins(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _confirmClearData,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BackupFormat format) async {
    setState(() => _isExporting = true);
    
    try {
      File exportFile;
      
      switch (format) {
        case BackupFormat.json:
          exportFile = await BackupService.exportToJson();
          break;
        case BackupFormat.csv:
          exportFile = await BackupService.exportToCsv();
          break;
        case BackupFormat.database:
          exportFile = await BackupService.exportDatabase();
          break;
      }

      await BackupService.shareBackup(exportFile, format);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _performSync() async {
    try {
      await CloudSyncService.performFullSync();
      _loadSyncStats(); // Refresh stats
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSyncSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Auto Sync', style: GoogleFonts.poppins()),
              subtitle: Text('Automatically sync every 15 minutes', style: GoogleFonts.poppins(fontSize: 12)),
              value: true, // Would be from settings
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text('Sync on WiFi Only', style: GoogleFonts.poppins()),
              subtitle: Text('Save mobile data', style: GoogleFonts.poppins(fontSize: 12)),
              value: false, // Would be from settings
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _importData() {
    // Implementation for importing data from file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import functionality would be implemented here')),
    );
  }

  void _restoreFromCloud() {
    // Implementation for restoring from cloud
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cloud restore functionality would be implemented here')),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete all your local expense data. This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete All', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    // Implementation for clearing all data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data clearing functionality would be implemented here')),
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
