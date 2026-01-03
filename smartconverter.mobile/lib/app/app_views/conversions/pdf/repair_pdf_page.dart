import '../../../app_modules/imports_module.dart';

class RepairPdfPage extends StatefulWidget {
  const RepairPdfPage({super.key});
  @override
  State<RepairPdfPage> createState() => _RepairPdfPageState();
}

class _RepairPdfPageState extends State<RepairPdfPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  File? _selectedFile;
  File? _resultFile;
  String? _savedFilePath;
  String? _targetDirectoryPath;
  String _statusMessage = 'Select a PDF file to begin.';
  bool _isProcessing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTargetDirectoryPath();
  }

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getRepairPdfDirectory();
      if (mounted) setState(() => _targetDirectoryPath = dir.path);
    } catch (_) {}
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final file = await _service.pickFile(allowedExtensions: const ['pdf'], type: 'pdf');
    if (file == null) {
      if (mounted) setState(() => _statusMessage = 'No file selected.');
      return;
    }
    setState(() {
      _selectedFile = file;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'PDF selected: ${basename(file.path)}';
      resetAdStatus(file.path);
    });
  }

  Future<void> _repairPdf() async {
    final file = _selectedFile;
    if (file == null) return;

    final adWatched = await showRewardedAdGate(toolName: 'Repair PDF');
    if (!adWatched) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Repairing…';
        _resultFile = null;
        _savedFilePath = null;
      });
    }
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.repairPdf(file, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Repair failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Repaired successfully';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Failed: $e');
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
      final dir = await FileManager.getRepairPdfDirectory();
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
    final pathToShare = _savedFilePath ?? _resultFile?.path;
    if (pathToShare == null) return;
    final f = File(pathToShare);
    if (!await f.exists()) return;
    await Share.shareXFiles([XFile(f.path)], text: 'Repaired PDF');
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _fileNameController.clear();
      resetAdStatus(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Repair PDF', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
                  title: 'Repair PDF',
                  description: 'Recover data from corrupted or damaged PDF files.',
                  iconTarget: Icons.build,
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
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: basenameWithoutExtension(_selectedFile!.path),
                    extensionLabel: '.pdf extension is preserved',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: _repairPdf,
                    isConverting: _isProcessing,
                    isEnabled: true,
                    buttonText: 'Repair PDF',
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
}
