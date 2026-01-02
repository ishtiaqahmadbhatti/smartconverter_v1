import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

class ImageQualityPage extends StatefulWidget {
  const ImageQualityPage({super.key});

  @override
  State<ImageQualityPage> createState() => _ImageQualityPageState();
}

class _ImageQualityPageState extends State<ImageQualityPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an image to adjust quality.');

  bool _isSaving = false;
  bool _isSharing = false;
  String? _savedFilePath;
  double _quality = 80;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController.removeListener(_handleFileNameChange);
    _fileNameController.dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    // handled by mixin if needed
  }

  // Mixin overrides
  @override
  ConversionModel get model => _model;
  @override
  TextEditingController get fileNameController => _fileNameController;
  @override
  ConversionService get service => _service;
  @override
  String get conversionToolName => 'Image Quality';
  @override
  String get fileTypeLabel => 'Image';
  @override
  String get targetExtension => 'jpg'; 
  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png', 'webp'];

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
    
    final toolDir = Directory('${imageRoot.path}/quality');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<ImageFormatConversionResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    final adWatched = await showRewardedAdGate(toolName: 'Image Quality');
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.changeImageQuality(
      file, 
      quality: _quality.toInt(),
      outputFilename: outputName
    );
  }

  Future<void> _saveFile() async {
    final result = model.conversionResult as ImageFormatConversionResult?;
    if (result == null) return;

    await showInterstitialAd();

    setState(() => _isSaving = true);

    try {
      final baseDir = await saveDirectory;
      String targetFileName = result.fileName;
      File destinationFile = File(p.join(baseDir.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          p.basenameWithoutExtension(targetFileName),
          p.extension(targetFileName).replaceAll('.', ''),
        );
        targetFileName = fallbackName;
        destinationFile = File(p.join(baseDir.path, targetFileName));
      }

      await result.file.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _savedFilePath = destinationFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to: ${destinationFile.path}'),
          backgroundColor: AppColors.success,
        ),
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

  Future<void> _shareFile() async {
    final result = model.conversionResult as ImageFormatConversionResult?;
    if (result == null) return;
    
    setState(() => _isSharing = true);
    try {
      final pathToShare = _savedFilePath ?? result.file.path;
      await Share.shareXFiles([XFile(pathToShare)], text: 'Adjusted Image Quality');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
          'Image Quality',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        leading: BackButton(color: AppColors.textPrimary),
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
                  title: 'Change Quality',
                  description: 'Adjust the compression quality of your image.',
                  iconTarget: Icons.high_quality,
                  iconSource: Icons.image,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'image'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Image',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.image,
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  
                  // Quality Slider
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quality', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                            Text('${_quality.toInt()}%', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: _quality,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          activeColor: AppColors.primaryBlue,
                          inactiveColor: AppColors.primaryBlue.withOpacity(0.3),
                          onChanged: (value) => setState(() => _quality = value),
                        ),
                        const Text('Lower quality reduces file size significantly.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: 'Original extension preserved',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Apply Changes',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  _buildResultsCard(),
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

  Widget _buildResultsCard() {
    final result = model.conversionResult as ImageFormatConversionResult?;
    if (result == null) return const SizedBox.shrink();

    // Calculate savings if possible
    String savings = '';
    if (model.selectedFile != null) {
      final originalSize = model.selectedFile!.lengthSync();
      final newSize = result.file.lengthSync();
      // Show savings or increase
      if (newSize < originalSize) {
         final percent = ((originalSize - newSize) / originalSize * 100).toStringAsFixed(1);
         savings = 'Saved $percent%';
      } else {
         savings = 'Size increased (higher quality)';
      }
    }

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
                child: const Icon(Icons.check_circle_outline, color: AppColors.textPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quality Adjusted',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      result.fileName,
                      style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 12),
                    ),
                    if (savings.isNotEmpty)
                      Text(
                        savings,
                        style: TextStyle(
                            color: savings.startsWith('Saved') ? AppColors.success : AppColors.warning, 
                            fontSize: 12, fontWeight: FontWeight.bold
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveFile,
                  icon: const Icon(Icons.save_alt),
                  label: Text(_isSaving ? 'Saving...' : 'Save File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareFile,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface.withOpacity(0.3),
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
