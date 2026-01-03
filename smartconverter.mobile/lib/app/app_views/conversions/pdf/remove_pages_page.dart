import '../../../app_modules/imports_module.dart';

class RemovePagesPage extends StatefulWidget {
  const RemovePagesPage({super.key});

  @override
  State<RemovePagesPage> createState() => _RemovePagesPageState();
}

class _RemovePagesPageState extends State<RemovePagesPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _rangesController = TextEditingController();
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

  @override
  void dispose() {
    _rangesController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getRemovePagesDirectory();
      if (mounted) {
        setState(() => _targetDirectoryPath = dir.path);
      }
    } catch (_) {}
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

  List<int> _parseRanges(String input) {
    // Basic logic to parse '1, 3-5' etc.
    final tokens = input.split(RegExp(r'[\,\s]+')).where((t) => t.trim().isNotEmpty).toList();
    final pages = <int>[];
    for (final token in tokens) {
      final t = token.trim();
      if (t.contains('-')) {
        final parts = t.split('-');
        final start = int.tryParse(parts.first.trim());
        final end = int.tryParse(parts.last.trim());
        if (start != null && end != null) {
          final a = start <= end ? start : end;
          final b = start <= end ? end : start;
          for (int i = a; i <= b; i++) {
            pages.add(i);
          }
        }
      } else {
        final num = int.tryParse(t);
        if (num != null) pages.add(num);
      }
    }
    final seen = <int>{};
    return pages.where((p) => seen.add(p)).toList();
  }

  Future<void> _removePages() async {
    final file = _selectedFile;
    if (file == null) return;
    final rangesText = _rangesController.text.trim();
    if (rangesText.isEmpty) {
      if (mounted) setState(() => _statusMessage = 'Enter pages to remove.');
      return;
    }

    final adWatched = await showRewardedAdGate(toolName: 'Remove Pages');
    if (!adWatched) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Removing pages…';
        _resultFile = null;
        _savedFilePath = null;
      });
    }

    try {
      final pages = _parseRanges(rangesText);
      final name = _fileNameController.text.trim();
      final res = await _service.removePages(file, pages, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Removal failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Pages removed successfully';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Removal failed: $e');
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
      final dir = await FileManager.getRemovePagesDirectory();
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
    await Share.shareXFiles([XFile(f.path)], text: 'Modified PDF');
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _rangesController.clear();
      _fileNameController.clear();
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
        title: const Text('Remove Pages', style: TextStyle(color: AppColors.textPrimary)),
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
                  title: 'Remove PDF Pages',
                  description: 'Delete specific pages from your PDF file easily.',
                  iconTarget: Icons.delete_sweep,
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
                  _buildRemovePagesOptionsCard(),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: basenameWithoutExtension(_selectedFile!.path),
                    extensionLabel: '.pdf extension is preserved',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: _removePages,
                    isConverting: _isProcessing,
                    isEnabled: true,
                    buttonText: 'Remove Pages',
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

  Widget _buildRemovePagesOptionsCard() {
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
            controller: _rangesController,
            decoration: InputDecoration(
              labelText: 'Pages to remove',
              hintText: 'e.g. 1, 3-5',
              prefixIcon: const Icon(Icons.layers_clear),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.backgroundSurface,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.datetime,
          ),
        ],
      ),
    );
  }
}
