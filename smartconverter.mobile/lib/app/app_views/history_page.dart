import 'dart:math';
import '../app_modules/imports_module.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ConversionService _conversionService = ConversionService();
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  String? _errorMessage;

  DateTime? _fromDate;
  DateTime? _toDate;
  final int _displayLimit = 5;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _historyItems = [];
        _totalCount = 0;
      });
    }

    try {
      final response = await _conversionService.getHistory(
        skip: isRefresh ? 0 : _historyItems.length,
        limit: _displayLimit,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      if (mounted) {
        setState(() {
          if (response != null) {
            if (isRefresh) {
              _historyItems = response.data;
            } else {
              _historyItems.addAll(response.data);
            }
            _totalCount = response.count;
          }
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load history. Please try again.';
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isMoreLoading || _historyItems.length >= _totalCount) return;

    setState(() {
      _isMoreLoading = true;
    });

    await _fetchHistory(isRefresh: false);
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Color(0xFF1E1B4B),
              surface: Colors.white,
              onSurface: Color(0xFF1E1B4B),
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Color(0xFF1E1B4B)),
              labelSmall: TextStyle(color: Color(0xFF1E1B4B)),
              headlineMedium: TextStyle(color: Color(0xFF1E1B4B)),
              labelLarge: TextStyle(color: Color(0xFF1E1B4B)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
      });
      _fetchHistory();
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E1B4B), // Explicit dark color
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Color(0xFF1E1B4B)),
              labelSmall: TextStyle(color: Color(0xFF1E1B4B)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
      _fetchHistory();
    }
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody()
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.1, duration: 800.ms);
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHistoryHeader(),
            const SizedBox(height: 16),
            _buildDateFilters(),
            const SizedBox(height: 24),
            const Text(
              'Latest Conversions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_historyItems.isEmpty)
              _buildEmptyState()
            else ...[
              _buildHistoryList(),
              if (_historyItems.length < _totalCount) _buildSeeMoreButton(),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: _isMoreLoading
            ? const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              )
            : TextButton.icon(
                onPressed: _loadMore,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                label: const Text(
                  'See More',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Conversion History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_fromDate != null || _toDate != null)
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(
              Icons.clear_all,
              size: 18,
              color: AppColors.textSecondary,
            ),
            label: const Text(
              'Reset',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildDateFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDatePicker(
              label: 'From',
              date: _fromDate,
              onTap: _selectFromDate,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDatePicker(
              label: 'To',
              date: _toDate,
              onTap: _selectToDate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.textTertiary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select Date',
                  style: TextStyle(
                    fontSize: 13,
                    color: date != null
                        ? AppColors.primaryDark
                        : AppColors.textTertiary,
                    fontWeight: date != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchHistory, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 56,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No history found for these dates',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundCard, AppColors.backgroundSurface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _historyItems.length,
        separatorBuilder: (context, index) =>
            const Divider(color: AppColors.backgroundSurface, height: 1),
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          return _buildActivityItem(item);
        },
      ),
    );
  }

  Widget _buildActivityItem(HistoryItem item) {
    Color statusColor;
    switch (item.status) {
      case 'success':
        statusColor = AppColors.secondaryGreen;
        break;
      case 'failed':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.primaryBlue;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.conversionType.replaceAll('-', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFileInfoRow(
            label: 'Input',
            fileName: item.inputFilename,
            fileSize: item.inputFileSize,
            icon: _getIconForType(
              item.inputFileType ?? item.conversionType.split('-').first,
            ),
            color: AppColors.textPrimary,
          ),
          if (item.outputFilename != null) ...[
            const SizedBox(height: 8),
            _buildFileInfoRow(
              label: 'Output',
              fileName: item.outputFilename!,
              fileSize: item.outputFileSize,
              icon: _getIconForType(
                item.outputFileType ?? item.conversionType.split('-').last,
              ),
              color: AppColors.secondaryGreen,
            ),
          ],
          if (item.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              item.errorMessage!,
              style: const TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileInfoRow({
    required String label,
    required String fileName,
    int? fileSize,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withOpacity(0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label: $fileName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (fileSize != null)
                Text(
                  _formatBytes(fileSize),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf;
    if (t.contains('image') ||
        t.contains('jpg') ||
        t.contains('png') ||
        t.contains('tiff') ||
        t.contains('svg'))
      return Icons.image;
    if (t.contains('word') || t.contains('doc')) return Icons.description;
    if (t.contains('excel') || t.contains('csv') || t.contains('xls'))
      return Icons.table_chart;
    if (t.contains('json') || t.contains('xml')) return Icons.code;
    if (t.contains('text') || t.contains('txt')) return Icons.text_snippet;
    if (t.contains('video')) return Icons.video_library;
    if (t.contains('audio')) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }
}
