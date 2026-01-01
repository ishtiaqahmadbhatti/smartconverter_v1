import '../../../app_modules/imports_module.dart';

class PdfMetadataPage extends StatefulWidget {
  const PdfMetadataPage({super.key});
  @override
  State<PdfMetadataPage> createState() => _PdfMetadataPageState();
}

class _PdfMetadataPageState extends State<PdfMetadataPage> with AdHelper {
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
    final dir = await FileManager.getMetadataPdfDirectory();
    setState(() => _targetDirectoryPath = dir.path);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final file = await _service.pickFile(allowedExtensions: const ['pdf'], type: 'pdf');
    if (file == null) {
      setState(() => _statusMessage = 'No file selected.');
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

  Future<void> _getMetadata() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Extracting metadata…';
      _resultFile = null;
      _savedFilePath = null;
    });

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Get PDF Metadata');
    if (!adWatched) {
      setState(() {
        _isProcessing = false;
        _statusMessage = 'Extraction cancelled (Ad required).';
      });
      return;
    }
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.getPdfMetadataFile(file, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Metadata extraction failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Metadata JSON ready';
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
    
    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);
    try {
      final dir = await FileManager.getMetadataPdfDirectory();
      String targetFileName = basename(res.path);
      File destinationFile = File('${dir.path}/$targetFileName');
      if (await destinationFile.exists()) {
        final fallback = FileManager.generateTimestampFilename(
          basenameWithoutExtension(targetFileName),
          'json',
        );
        targetFileName = fallback;
        destinationFile = File('${dir.path}/$targetFileName');
      }
      final saved = await res.copy(destinationFile.path);
      if (!mounted) return;
      
      setState(() => _savedFilePath = saved.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: saved.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'Metadata saved successfully!';
        });
      }
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
    await Share.shareXFiles([XFile(f.path)], text: 'PDF Metadata');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Get PDF Metadata', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Get Metadata',
                  description: 'Extract metadata information from PDF files.',
                  iconTarget: Icons.data_object,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => _pickPdfFile(),
                  isFileSelected: _selectedFile != null,
                  isConverting: _isProcessing,
                  onReset: () {
                    setState(() {
                       _selectedFile = null;
                       _resultFile = null;
                       _savedFilePath = null;
                       _statusMessage = 'Select a PDF file';
                       _fileNameController.clear();
                    });
                  },
                  buttonText: 'Select PDF',
                ),
                const SizedBox(height: 16),
                
                if (_selectedFile != null)
                   ConversionSelectedFileCardWidget(
                    fileName: basename(_selectedFile!.path),
                    fileSize: _formatBytes(_selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: () {
                      setState(() {
                         _selectedFile = null;
                         _resultFile = null;
                      });
                    },
                   ),

                const SizedBox(height: 12),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 12),
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: null,
                    extensionLabel: '.json',
                  ),
                  const SizedBox(height: 12),
                   ConversionConvertButtonWidget(
                      onConvert: _getMetadata,
                      isConverting: _isProcessing,
                      isEnabled: true,
                      buttonText: 'Get Metadata',
                    ),
                ],
                const SizedBox(height: 12),
                ConversionStatusWidget(
                  isConverting: _isProcessing,
                  statusMessage: _statusMessage,
                ),
                if (_resultFile != null) ...[
                  const SizedBox(height: 20),
                  if (_savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: basename(_resultFile!.path),
                      isSaving: _isSaving,
                      onSave: _saveResult,
                      title: 'Metadata Ready',
                    )
                  else
                    ConversionResultCardWidget(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareResult,
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final value = bytes / pow(1024, digitGroups);
    return '${value.toStringAsFixed(value >= 10 || digitGroups == 0 ? 0 : 1)} ${units[digitGroups]}';
  }
}
