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
  bool _zip = false;
  bool _isProcessing = false;
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
      _statusMessage = 'PDF file selected: ${basename(file.path)}';
      _prefixCtrl.text = basenameWithoutExtension(file.path);
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
        zip: _zip,
      );
      if (mounted) {
        setState(() {
          _results = result?.files ?? [];
          _statusMessage = 'Split completed: ${_results.length} files.';
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

    final baseDir = await FileManager.getSplitPdfsDirectory();
    String targetFolder = _prefixCtrl.text.trim().isEmpty
        ? (_selectedFile != null
              ? basenameWithoutExtension(_selectedFile!.path)
              : 'split')
        : _prefixCtrl.text.trim();
    Directory destination = Directory(join(baseDir.path, targetFolder));
    int counter = 1;
    while (await destination.exists()) {
      destination = Directory(join(baseDir.path, '${targetFolder}_$counter'));
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
        await tmp.copy(join(destination.path, part.fileName));
        anySaved = true;
      }
    }
    
    if (anySaved && mounted) {
      setState(() => _savedFolderPath = destination.path);
      
      await NotificationService.showFileSavedNotification(
        fileName: targetFolder,
        filePath: destination.path,
      );

      setState(() => _statusMessage = 'Files saved to $targetFolder');
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
                    fileSize: formatBytes(_selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: _reset,
                  ),
                  const SizedBox(height: 16),
                  _buildOptionsCard(),
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
                  conversionResult: null, // Using custom result view
                ),
                if (_results.isNotEmpty) ...[
                   const SizedBox(height: 20),
                   _buildResultsList(),
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
          const SizedBox(height: 12),
          TextField(
            controller: _prefixCtrl,
            decoration: InputDecoration(
              labelText: 'Output prefix',
              hintText: 'Auto from file name',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.backgroundSurface,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _zip,
            onChanged: (v) => setState(() => _zip = v),
            activeColor: AppColors.primaryBlue,
            title: const Text(
              'Return zip also',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
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
                  color: AppColors.backgroundSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
               const SizedBox(width: 12),
               const Expanded(
                 child: Text(
                   'Split Results',
                   style: TextStyle(
                     color: AppColors.textPrimary,
                     fontSize: 16,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
               if (_results.isNotEmpty)
                 TextButton.icon(
                   onPressed: _savePartsLocally,
                   icon: const Icon(Icons.save_alt, color: AppColors.textPrimary),
                   label: const Text('Save All', style: TextStyle(color: AppColors.textPrimary)),
                 ),
            ],
          ),
          const SizedBox(height: 16),
          if (_savedFolderPath != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Saved to folder: ${_savedFolderPath!.split(Platform.pathSeparator).last}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final r = _results[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(
                    r.fileName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Pages: ${r.pages.join(', ')}',
                    style: TextStyle(color: AppColors.textPrimary.withOpacity(0.7), fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: AppColors.textPrimary, size: 20),
                    onPressed: () async {
                      final f = await _service.downloadConvertedFile(
                        r.downloadUrl,
                        r.fileName,
                      );
                      if (f != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloaded ${r.fileName}')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }
}
