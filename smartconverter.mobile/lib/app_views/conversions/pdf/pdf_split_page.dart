import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/app_colors.dart';
import '../../../services/admob_service.dart';
import '../../../services/conversion_service.dart';
import '../../../services/notification_service.dart';
// import '../../../app_widgets/conversion_result_card_widget.dart'; // Not using for split as it returns a list/folder
import '../../../utils/file_manager.dart';
import '../../../utils/ad_helper.dart';
import '../../../app_models/conversion_tool.dart';

class PdfSplitPage extends StatefulWidget {
  const PdfSplitPage({super.key});
  @override
  State<PdfSplitPage> createState() => _PdfSplitPageState();
}

class _PdfSplitPageState extends State<PdfSplitPage> with AdHelper {
  final ConversionService _service = ConversionService();
  // final AdMobService _admobService = AdMobService(); // Handled by AdHelper
  final TextEditingController _prefixCtrl = TextEditingController();
  final TextEditingController _rangesCtrl = TextEditingController();
  File? _selectedFile;
  String _splitType = 'page_ranges';
  bool _zip = false;
  bool _isProcessing = false;
  BannerAd? _bannerAd;
  bool _isBannerReady = false;
  List<SplitFileResult> _results = [];
  String? _savedFolderPath;
  String _statusMessage = 'Select a PDF file to begin.';
  String? _targetDirectoryPath;

  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getSplitPdfsDirectory();
      if (mounted) {
        setState(() => _targetDirectoryPath = dir.path);
      }
    } catch (_) {}
  }

  Future<void> _pickPdfFile() async {
    final file = await _service.pickFile(
      allowedExtensions: const ['pdf'],
      type: 'pdf',
    );
    if (file == null) {
      setState(() => _statusMessage = 'No file selected.');
      return;
    }
    setState(() {
      _selectedFile = file;
      _results = [];
      _savedFolderPath = null;
      _statusMessage = 'PDF file selected: ${p.basename(file.path)}';
      _prefixCtrl.text = p.basenameWithoutExtension(file.path);
      resetAdStatus(file.path);
    });
  }

  Future<void> _splitPdf() async {
    if (_selectedFile == null) {
      setState(() => _statusMessage = 'Please select a PDF file first.');
      return;
    }
    setState(() => _isProcessing = true);

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Split PDF');
    if (!adWatched) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Split cancelled (Ad required).';
      });
      return;
    }

    try {
      final prefix = _prefixCtrl.text.trim().isEmpty
          ? p.basenameWithoutExtension(_selectedFile!.path)
          : _prefixCtrl.text.trim();
      final ranges = _splitType == 'page_ranges'
          ? _rangesCtrl.text.trim()
          : null;
      final result = await _service.splitPdf(
        _selectedFile!,
        splitType: _splitType,
        pageRanges: ranges,
        outputPrefix: prefix,
        zip: _zip,
      );
      setState(() {
        _results = result?.files ?? [];
        _statusMessage = 'Split completed: ${_results.length} files.';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Split failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _savePartsLocally() async {
    if (_results.isEmpty) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    final baseDir = await FileManager.getSplitPdfsDirectory();
    String targetFolder = _prefixCtrl.text.trim().isEmpty
        ? (_selectedFile != null
              ? p.basenameWithoutExtension(_selectedFile!.path)
              : 'split')
        : _prefixCtrl.text.trim();
    Directory destination = Directory(p.join(baseDir.path, targetFolder));
    int counter = 1;
    while (await destination.exists()) {
      destination = Directory(p.join(baseDir.path, '${targetFolder}_$counter'));
      counter++;
    }
    await destination.create(recursive: true);
    
    bool anySaved = false;
    for (final part in _results) {
      final tmp = await _service.downloadConvertedFile(
        part.downloadUrl,
        part.fileName,
      );
      if (tmp != null) {
        await tmp.copy(p.join(destination.path, part.fileName));
        anySaved = true;
      }
    }
    
    if (anySaved) {
      setState(() => _savedFolderPath = destination.path);
      
       // Trigger System Notification (Using first file or just generic info? The widget expects file path, but we have a folder. 
       // I'll pass the folder path, it might try to open it if supported, or just show the path.)
      await NotificationService.showFileSavedNotification(
        fileName: targetFolder,
        filePath: destination.path,
      );

      if (mounted) {
         setState(() => _statusMessage = 'Files saved to $targetFolder');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Split PDF',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPickerCard(),
                const SizedBox(height: 12),
                _buildOptionsCard(),
                const SizedBox(height: 12),
                _buildSplitButton(),
                const SizedBox(height: 12),
                _buildStatusMessage(),
                if (_results.isNotEmpty) ...[
                   const SizedBox(height: 12),
                   _buildResultsList(),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _statusMessage,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _buildPickerCard() {
    final name = _selectedFile != null
        ? p.basename(_selectedFile!.path)
        : 'No file selected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select PDF',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickPdfFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Choose',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _targetDirectoryPath != null
                ? 'Will save under: $_targetDirectoryPath'
                : 'Will save under: Documents/SmartConverter/PDFConversions/split_pdfs',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Radio<String>(
                value: 'every_page',
                groupValue: _splitType,
                onChanged: (v) => setState(() => _splitType = v!),
              ),
              const Text(
                'Every page',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 16),
              Radio<String>(
                value: 'page_ranges',
                groupValue: _splitType,
                onChanged: (v) => setState(() => _splitType = v!),
              ),
              const Text(
                'Page ranges',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rangesCtrl,
            enabled: _splitType == 'page_ranges',
            decoration: const InputDecoration(
              labelText: 'Page ranges',
              hintText: 'e.g., 1-4,5,30,45-50',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textTertiary),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _prefixCtrl,
            decoration: const InputDecoration(
              labelText: 'Output prefix',
              hintText: 'Auto from file name',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textTertiary),
              ),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _zip,
            onChanged: (v) => setState(() => _zip = v),
            title: const Text(
              'Return zip also',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (_selectedFile == null || _isProcessing) ? null : _splitPdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          _isProcessing ? 'Splitting…' : 'Split PDF',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               const Expanded(
                 child: Text(
                   'Split Results',
                   style: TextStyle(
                     color: AppColors.textPrimary,
                     fontSize: 16,
                     fontWeight: FontWeight.w600,
                   ),
                 ),
               ),
               if (_results.isNotEmpty)
                 TextButton.icon(
                   onPressed: _savePartsLocally,
                   icon: const Icon(Icons.save_alt),
                   label: const Text('Save All'),
                 ),
            ],
          ),
          const SizedBox(height: 8),
          if (_savedFolderPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Saved folder: $_savedFolderPath',
                style: const TextStyle(color: AppColors.success, fontSize: 12),
              ),
            ),
          ..._results.map(
            (r) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                title: Text(
                  r.fileName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
                subtitle: Text(
                  'Pages: ${r.pages.join(', ')}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     IconButton(
                       icon: const Icon(Icons.download, color: AppColors.primaryBlue),
                       onPressed: () async {
                         final f = await _service.downloadConvertedFile(
                           r.downloadUrl,
                           r.fileName,
                         );
                         if (f != null && mounted) {
                           // Individual file download notification or snackbar? 
                           // Keeping snackbar for individual downloads to avoid spamming notification center
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Downloaded ${r.fileName}')),
                           );
                         }
                       },
                     ),
                     IconButton(
                        icon: const Icon(Icons.share, color: AppColors.primaryBlue),
                        onPressed: () async {
                           final f = await _service.downloadConvertedFile(
                             r.downloadUrl,
                             r.fileName,
                           );
                           if (f != null) {
                             await Share.shareXFiles([
                               XFile(f.path),
                             ], text: 'Split part: ${r.fileName}');
                           }
                        },
                     ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
