import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_drawer.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return _buildBody()
          .animate()
          .fadeIn(duration: 800.ms)
          .slideY(begin: 0.1, duration: 800.ms);
  }


  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Conversion Activities',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Clear history logic
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundCard,
                AppColors.backgroundSurface,
              ],
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
          child: Column(
            children: [
              _buildActivityItem(
                'document.pdf',
                'PDF to Word',
                '2 minutes ago',
                AppColors.secondaryGreen,
              ),
              const Divider(color: AppColors.backgroundSurface),
              _buildActivityItem(
                'image.jpg',
                'Image to PDF',
                '5 minutes ago',
                AppColors.primaryBlue,
              ),
              const Divider(color: AppColors.backgroundSurface),
              _buildActivityItem(
                'spreadsheet.xlsx',
                'Excel to PDF',
                '10 minutes ago',
                AppColors.primaryPurple,
              ),
              const Divider(color: AppColors.backgroundSurface),
              _buildActivityItem(
                'presentation.pptx',
                'PPT to PDF',
                '1 hour ago',
                AppColors.accentOrange,
              ),
              const Divider(color: AppColors.backgroundSurface),
              _buildActivityItem(
                'audio.mp3',
                'MP3 to WAV',
                '2 hours ago',
                AppColors.secondaryGreen,
              ),
              const Divider(color: AppColors.backgroundSurface),
              _buildActivityItem(
                'video.mp4',
                'MP4 to MP3',
                '5 hours ago',
                AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String fileName,
    String conversionType,
    String time,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description, color: statusColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conversionType,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.download_done, size: 16, color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }
}
