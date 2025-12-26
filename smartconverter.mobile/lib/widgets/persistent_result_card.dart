import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';

import '../constants/app_colors.dart';
import '../services/notification_service.dart';
import '../views/my_files_page.dart';

class PersistentResultCard extends StatefulWidget {
  final String savedFilePath;
  final VoidCallback onShare;
  final String title;

  const PersistentResultCard({
    super.key,
    required this.savedFilePath,
    required this.onShare,
    this.title = 'CONVERSION RESULT',
  });

  @override
  State<PersistentResultCard> createState() => _PersistentResultCardState();
}

class _PersistentResultCardState extends State<PersistentResultCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.success.withOpacity(0.5), thickness: 2, height: 1),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '⭐ Saved File – Quick Access ⭐',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'APP LOCATION:',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
             child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _buildAppLocationPath(widget.savedFilePath),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              height: 48,
              width: 260,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyFilesPage(
                        initialPath: p.dirname(widget.savedFilePath),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 25, color: Colors.white),
                label: const Text(
                  'Go To App Location', 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'DEVICE LOCATION:',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.savedFilePath.replaceFirst('/storage/emulated/0/', ''),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              height: 48,
              width: 260,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                   final folderPath = p.dirname(widget.savedFilePath);
                   await NotificationService.openFile(folderPath);
                },
                icon: const Icon(Icons.arrow_forward, size: 25, color: Colors.white),
                label: const Text(
                  'Go To Device Location', 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.success.withOpacity(0.5), thickness: 2, height: 1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                       if (!await File(widget.savedFilePath).exists()) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File no longer exists.')),
                            );
                          }
                          return;
                       }
                       await NotificationService.openFile(widget.savedFilePath);
                    },
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Open File'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 130,
                  child: OutlinedButton.icon(
                    onPressed: widget.onShare,
                    icon: const Icon(Icons.share, size: 14),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Share'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppLocationPath(String fullPath) {
    List<Widget> widgets = [];

    // 1. Drawer Menu Icon
    widgets.add(
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.menu, color: AppColors.textPrimary, size: 14),
      ),
    );

    // Separator
    widgets.add(const Icon(Icons.chevron_right, size: 20, color: AppColors.primaryBlue));

    // 2. My Files Group
    widgets.add(
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 16, color: AppColors.primaryBlue),
          SizedBox(width: 2),
          Text(
            'My Files',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontFamily: 'monospace'),
          ),
        ],
      ),
    );

    // Separator
    widgets.add(const Icon(Icons.chevron_right, size: 20, color: AppColors.primaryBlue));

    // 3. SmartConverter part
    String relativePath = '';
    if (fullPath.contains('SmartConverter')) {
      final parts = fullPath.split('SmartConverter');
      if (parts.length > 1) {
        relativePath = 'SmartConverter${parts.sublist(1).join('SmartConverter')}';
      } else {
        relativePath = 'SmartConverter';
      }
    } else {
      relativePath = p.basename(fullPath);
    }

    // Split and add segments
    relativePath = relativePath.replaceAll('\\', '/');
    if (relativePath.startsWith('/')) relativePath = relativePath.substring(1);
    
    final segments = relativePath.split('/');
    
    for (int i = 0; i < segments.length; i++) {
        if (segments[i].isEmpty) continue;
        
        final isLast = i == segments.length - 1;
        
        widgets.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(
                  isLast ? Icons.insert_drive_file : Icons.folder,
                  size: 16, 
                  color: isLast ? AppColors.textPrimary : AppColors.primaryBlue
              ),
              const SizedBox(width: 2),
              Text(
                segments[i],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
        
        if (!isLast) {
           widgets.add(const Icon(Icons.chevron_right, size: 20, color: AppColors.primaryBlue));
        }
    }

    return widgets;
  }
}
