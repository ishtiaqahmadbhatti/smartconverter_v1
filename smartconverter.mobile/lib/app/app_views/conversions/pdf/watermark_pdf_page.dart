import '../../../app_modules/imports_module.dart';

class WatermarkPdfPage extends StatefulWidget {
  const WatermarkPdfPage({super.key});

  @override
  State<WatermarkPdfPage> createState() => _WatermarkPdfPageState();
}

class _WatermarkPdfPageState extends State<WatermarkPdfPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _watermarkController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;

  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;

  String _position = 'center';

  final List<String> _positions = const [
    'top-left',
    'top-center',
    'top-right',
    'middle-left',
    'center',
    'middle-right',
    'bottom-left',
    'bottom-center',
    'bottom-right',
    'top-left-diagonal',
    'top-center-diagonal',
    'top-right-diagonal',
    'middle-left-diagonal',
    'center-diagonal',
    'middle-right-diagonal',
    'bottom-left-diagonal',
    'bottom-center-diagonal',
    'bottom-right-diagonal',
  ];

  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
  }

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getWatermarkPdfDirectory();
      if (mounted) setState(() => _targetDirectoryPath = dir.path);
    } catch (_) {}
  }

  @override
  void dispose() {
    _watermarkController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await _service.pickFile(
      allowedExtensions: const ['pdf'],
      type: 'pdf',
    );
    if (file != null) {
      if (mounted) {
        setState(() {
          _selectedFile = file;
          _resultFile = null;
           _savedFilePath = null;
          _statusMessage = 'PDF selected: ${basename(file.path)}';
          resetAdStatus(file.path);
        });
      }
    }
  }

  Future<void> _applyWatermark() async {
    final file = _selectedFile;
    if (file == null) return;

    final text = _watermarkController.text.trim();
    if (text.isEmpty) {
      setState(() => _statusMessage = 'Watermark text is required.');
      return;
    }

    final adWatched = await showRewardedAdGate(toolName: 'Watermark PDF');
    if (!adWatched) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _resultFile = null;
        _savedFilePath = null;
        _statusMessage = 'Applying watermark...';
      });
    }

    try {
      final name = _fileNameController.text.trim();
      final res = await _service.watermarkPdf(
        file,
        text,
        _position,
        outputFilename: name.isNotEmpty ? name : null,
      );
      if (!mounted) return;
      if (res != null) {
        setState(() {
          _resultFile = res;
          _statusMessage = 'Watermark applied successfully';
        });
      } else {
        setState(() => _statusMessage = 'Failed to apply watermark.');
      }
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveResult() async {
    final res = _resultFile;
    if (res == null) return;
    
    await showInterstitialAd();

    if (mounted) setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getWatermarkPdfDirectory();
      String targetFileName = basename(res.path);
      File destinationFile = File('${dir.path}/$targetFileName');
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          basenameWithoutExtension(targetFileName),
          'pdf',
        );
        targetFileName = fallback;
        destinationFile = File('${dir.path}/$targetFileName');
      }
      final saved = await res.copy(destinationFile.path);
      if (!mounted) return;
      
      setState(() => _savedFilePath = saved.path);
      
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: saved.path,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareResult() async {
    final path = _savedFilePath ?? _resultFile?.path;
    if (path == null) return;
    final f = File(path);
    if (!await f.exists()) return;
    await Share.shareXFiles([XFile(path)], text: 'Watermarked PDF');
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _watermarkController.clear();
      _fileNameController.clear();
      _position = 'center';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Watermark', style: TextStyle(color: AppColors.textPrimary)),
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
                  title: 'Add Watermark',
                  description: 'Add text watermarks to your PDF files.',
                  iconTarget: Icons.water_drop,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: _pickFile,
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
                  _buildWatermarkOptionsCard(),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: basenameWithoutExtension(_selectedFile!.path),
                    extensionLabel: '.pdf extension is preserved',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: _applyWatermark,
                    isConverting: _isProcessing,
                    isEnabled: true,
                    buttonText: 'Apply Watermark',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: _statusMessage,
                  isConverting: _isProcessing,
                  conversionResult: null,
                ),
                if (_resultFile != null) ...[
                  const SizedBox(height: 20),
                   _savedFilePath == null 
                    ? ConversionFileSaveCardWidget(
                        fileName: basename(_resultFile!.path),
                        isSaving: _isSaving,
                        onSave: _saveResult,
                        title: 'PDF File Ready',
                      )
                    : ConversionResultCardWidget(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareResult,
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

  Widget _buildWatermarkOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _watermarkController,
            decoration: InputDecoration(
              labelText: 'Watermark Text',
              hintText: 'Enter watermark text',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.backgroundSurface,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _position,
                isExpanded: true,
                hint: const Text('Select Position', style: TextStyle(color: AppColors.textSecondary)),
                dropdownColor: AppColors.backgroundCard,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                items: _positions.map((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e.replaceAll('-', ' ').toUpperCase()),
                )).toList(),
                onChanged: _isProcessing ? null : (v) => setState(() => _position = v ?? 'center'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
