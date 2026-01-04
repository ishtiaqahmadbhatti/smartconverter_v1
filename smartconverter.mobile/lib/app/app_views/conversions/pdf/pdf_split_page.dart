import '../../../app_modules/imports_module.dart';

class PdfSplitPage extends StatefulWidget {
  const PdfSplitPage({super.key});
  @override
  State<PdfSplitPage> createState() => _PdfSplitPageState();
}

class _PdfSplitPageState extends State<PdfSplitPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _prefixCtrl = TextEditingController();
  final TextEditingController _rangesCtrl = TextEditingController();
  File? _selectedFile;
  String _splitType = 'page_ranges';
  bool _isProcessing = false;
  bool _isSaving = false;
  List<SplitFileResult> _results = [];
  String? _savedFolderPath;
  String _statusMessage = 'Select a PDF file to begin.';
  String? _targetDirectoryPath;

  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
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
    try {
      final file = await _service.pickFile(
        allowedExtensions: const ['pdf'],
        type: 'pdf',
      );
      if (file == null) {
        if (mounted) setState(() => _statusMessage = 'No file selected.');
        return;
      }
      setState(() {
        _selectedFile = file;
        _results = [];
        _savedFolderPath = null;
        _statusMessage = '1 PDF file selected.';
        _prefixCtrl.text = basenameWithoutExtension(file.path);
        resetAdStatus(file.path);
      });
    } catch (e) {
       if (mounted) setState(() => _statusMessage = 'Error picking file: $e');
    }
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
          ? basenameWithoutExtension(_selectedFile!.path)
          : _prefixCtrl.text.trim();
      final ranges = _splitType == 'page_ranges'
          ? _rangesCtrl.text.trim()
          : null;
      final result = await _service.splitPdf(
        _selectedFile!,
        splitType: _splitType,
        pageRanges: ranges,
        outputPrefix: prefix,
      );
      if (mounted) {
        setState(() {
          _results = result?.files ?? [];
          _statusMessage = 'Split completed: ${_results.length} files created.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'Split failed: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _savePartsLocally() async {
    if (_results.isEmpty) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);
    try {
      final baseDir = await FileManager.getSplitPdfsDirectory();
      String targetFolder = _prefixCtrl.text.trim().isEmpty
          ? (_selectedFile != null
                ? basenameWithoutExtension(_selectedFile!.path)
                : 'split')
          : _prefixCtrl.text.trim();
    Directory destination = Directory(join(baseDir.path, targetFolder));
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }
    
    bool anySaved = false;
    for (final part in _results) {
      final tmp = await _service.downloadConvertedFile(
        part.downloadUrl,
        part.fileName,
      );
      if (tmp != null) {
        await tmp.copy(join(destination.path, part.fileName));
        anySaved = true;
      }
    }
    
    if (anySaved && mounted) {
      setState(() => _savedFolderPath = destination.path);
      
      await NotificationService.showFileSavedNotification(
        fileName: basename(destination.path),
        filePath: destination.path,
        showOpenFileButton: false, 
      );

      setState(() => _statusMessage = 'Files saved to folder: ${basename(destination.path)}');
    }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _results = [];
      _savedFolderPath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _prefixCtrl.clear();
      _rangesCtrl.clear();
      resetAdStatus(null);
    });
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }

  String getSafeFileSize(File file) {
    try {
      if (!file.existsSync()) return 'File not found';
      return formatBytes(file.lengthSync());
    } catch (e) {
      return 'Unknown size';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Split PDF',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Split PDF',
                  description: 'Split your PDF into multiple files by page ranges or extract all pages.',
                  iconTarget: Icons.call_split,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: _pickPdfFile,
                  isFileSelected: _selectedFile != null,
                  isConverting: _isProcessing,
                  onReset: _reset,
                  buttonText: 'Select PDF File',
                ),
                const SizedBox(height: 16),
                if (_selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(_selectedFile!.path),
                    fileSize: getSafeFileSize(_selectedFile!),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: _reset,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionsCard(),
                   const SizedBox(height: 16),
                   ConversionFileNameFieldWidget(
                     controller: _prefixCtrl,
                     suggestedName: basenameWithoutExtension(_selectedFile!.path),
                     extensionLabel: 'Folder Name',
                   ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: _splitPdf,
                    isConverting: _isProcessing,
                    isEnabled: true,
                    buttonText: 'Split PDF',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: _statusMessage,
                  isConverting: _isProcessing,
                  conversionResult: null,
                ),
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _savedFolderPath == null
                    ? ConversionFileSaveCardWidget(
                        fileName: '${_results.length} Files Ready',
                        isSaving: _isSaving,
                        onSave: _savePartsLocally,
                        title: 'Split Files Ready',
                      )
                    : ConversionResultCardWidget(
                        savedFilePath: _savedFolderPath!,
                        onShare: () {}, // Share logic not applicable for folder in this context or handled externally
                        showActions: false, // Hides Open/Share buttons as requested
                      ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
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
                fillColor: MaterialStateProperty.all(AppColors.primaryBlue),
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
                fillColor: MaterialStateProperty.all(AppColors.primaryBlue),
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
            decoration: InputDecoration(
              labelText: 'Page ranges',
              hintText: 'e.g., 1-4,5,30,45-50',
              prefixIcon: const Icon(Icons.format_list_numbered),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.backgroundSurface,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
