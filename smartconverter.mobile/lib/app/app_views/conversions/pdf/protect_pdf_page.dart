import '../../../app_modules/imports_module.dart';

class ProtectPdfPage extends StatefulWidget {
  const ProtectPdfPage({super.key});
  @override
  State<ProtectPdfPage> createState() => _ProtectPdfPageState();
}

class _ProtectPdfPageState extends State<ProtectPdfPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _passwordController = TextEditingController();
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
      final dir = await FileManager.getProtectPdfDirectory();
      if (mounted) setState(() => _targetDirectoryPath = dir.path);
    } catch (_) {}
  }

  @override
  void dispose() {
    _passwordController.dispose();
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

  Future<void> _protectPdf() async {
    final file = _selectedFile;
    if (file == null) return;
    final pwd = _passwordController.text;
    if (pwd.isEmpty) {
      setState(() => _statusMessage = 'Password is required.');
      return;
    }

    final adWatched = await showRewardedAdGate(toolName: 'Protect PDF');
    if (!adWatched) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _statusMessage = 'Protecting…';
        _resultFile = null;
        _savedFilePath = null;
      });
    }
    try {
      final name = _fileNameController.text.trim();
      final res = await _service.protectPdf(file, pwd, outputFilename: name.isNotEmpty ? name : null);
      if (!mounted) return;
      if (res == null) {
        setState(() => _statusMessage = 'Protection failed.');
        return;
      }
      setState(() {
        _resultFile = res;
        _statusMessage = 'Protected successfully';
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
      final dir = await FileManager.getProtectPdfDirectory();
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
    await Share.shareXFiles([XFile(f.path)], text: 'Protected PDF');
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _resultFile = null;
      _savedFilePath = null;
      _statusMessage = 'Select a PDF file to begin.';
      _passwordController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Protect PDF', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
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
                  title: 'Protect PDF',
                  description: 'Add password protection to your PDF files securely.',
                  iconTarget: Icons.lock_outline,
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
                    onConvert: _protectPdf,
                    isConverting: _isProcessing,
                    isEnabled: true,
                    buttonText: 'Protect PDF',
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
                   _savedFilePath != null 
                    ? ConversionResultCardWidget(
                        savedFilePath: _savedFilePath!,
                        onShare: _shareResult,
                      )
                    : _buildResultCard(),
                ],
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
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password (Required)',
              hintText: 'Enter password',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: AppColors.backgroundSurface,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fileNameController,
            decoration: InputDecoration(
              labelText: 'Output file name (Optional)',
              hintText: 'Enter custom name',
              prefixIcon: const Icon(Icons.edit_outlined),
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

  Widget _buildResultCard() {
    final res = _resultFile!;
    return Container(
      padding: const EdgeInsets.all(20),
      // Standard result styling used in other pages
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
                  Icons.lock,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PDF Protected',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      basename(res.path),
                      style: TextStyle(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
               Flexible(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveResult,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _shareResult,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
