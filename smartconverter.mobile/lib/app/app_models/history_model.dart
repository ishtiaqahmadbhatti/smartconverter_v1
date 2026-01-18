class HistoryItem {
  final int id;
  final DateTime createdAt;
  final String conversionType;
  final String inputFilename;
  final int? inputFileSize;
  final String? inputFileType;
  final String? outputFilename;
  final int? outputFileSize;
  final String? outputFileType;
  final String status;
  final String? errorMessage;
  final String? downloadUrl;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.conversionType,
    required this.inputFilename,
    this.inputFileSize,
    this.inputFileType,
    this.outputFilename,
    this.outputFileSize,
    this.outputFileType,
    required this.status,
    this.errorMessage,
    this.downloadUrl,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      conversionType: json['conversion_type'],
      inputFilename: json['input_filename'],
      inputFileSize: json['input_file_size'],
      inputFileType: json['input_file_type'],
      outputFilename: json['output_filename'],
      outputFileSize: json['output_file_size'],
      outputFileType: json['output_file_type'],
      status: json['status'],
      errorMessage: json['error_message'],
      downloadUrl: json['download_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'conversion_type': conversionType,
      'input_filename': inputFilename,
      'input_file_size': inputFileSize,
      'input_file_type': inputFileType,
      'output_filename': outputFilename,
      'output_file_size': outputFileSize,
      'output_file_type': outputFileType,
      'status': status,
      'error_message': errorMessage,
      'download_url': downloadUrl,
    };
  }

  String get formattedDate {
    // Simple formatting or use intl package if available
    // For now, simple format: YYYY-MM-DD HH:mm
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}

class HistoryListResponse {
  final bool success;
  final List<HistoryItem> data;
  final int count;

  HistoryListResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    return HistoryListResponse(
      success: json['success'],
      data: (json['data'] as List).map((i) => HistoryItem.fromJson(i)).toList(),
      count: json['count'],
    );
  }
}

class UsageStats {
  final bool success;
  final int filesConverted;
  final int dataProcessedBytes;
  final int daysActive;

  UsageStats({
    required this.success,
    required this.filesConverted,
    required this.dataProcessedBytes,
    required this.daysActive,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      success: json['success'] ?? false,
      filesConverted: json['files_converted'] ?? 0,
      dataProcessedBytes: json['data_processed_bytes'] ?? 0,
      daysActive: json['days_active'] ?? 0,
    );
  }
}
