import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

class ImageFormatConversionPage extends StatefulWidget {
  final String toolName;
  final String sourceFormat; // e.g., 'PNG'
  final String targetFormat; // e.g., 'JPG'
  final String sourceExtension; // e.g., 'png'
  final String targetExtension; // e.g., 'jpg'
  final String apiEndpoint;

  const ImageFormatConversionPage({
    super.key,
    required this.toolName,
    required this.sourceFormat,
    required this.targetFormat,
    required this.sourceExtension,
    required this.targetExtension,
    required this.apiEndpoint,
  });

  @override
  State<ImageFormatConversionPage> createState() => _ImageFormatConversionPageState();
}

class _ImageFormatConversionPageState extends State<ImageFormatConversionPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  late final ConversionModel _model;

  bool _isSaving = false;
  bool _isSharing = false;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _model = ConversionModel(statusMessage: 'Select a ${widget.sourceFormat} file to begin.');
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
  String get conversionToolName => widget.toolName;
  @override
  String get fileTypeLabel => widget.sourceFormat;
  @override
  String get targetExtension => widget.targetExtension;
  @override
  List<String> get allowedExtensions {
    // If sourceExtension is generic "image", allow common formats? 
    // The previous code had strict checking unless "image".
    if (widget.sourceExtension.toLowerCase() == 'image') {
       return ['png', 'jpg', 'jpeg', 'webp', 'bmp', 'tiff', 'heic']; // Common image formats
    }
    return [widget.sourceExtension.toLowerCase()];
  }

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
    
    // Create standard subfolder: src-to-tgt
    // Ensure lowercase and kebab-case style if needed, though extension passes are usually simple
    // Example: png-to-jpg
    final subFolderName = '${widget.sourceExtension.toLowerCase()}-to-${widget.targetExtension.toLowerCase()}';
    final toolDir = Directory('${imageRoot.path}/$subFolderName');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<ImageFormatConversionResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    // Ad check
    final adWatched = await showRewardedAdGate(toolName: widget.toolName);
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.convertImageFormat(
      file: file,
      apiEndpoint: widget.apiEndpoint,
      targetExtension: widget.targetExtension,
      outputFilename: outputName,
    );
  }

  Future<void> _saveFile() async {
    final result = model.conversionResult as ImageFormatConversionResult?;
    if (result == null) return;

    // Show Interstitial Ad before saving
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
      await Share.shareXFiles(
        [XFile(pathToShare)],
        text: 'Converted ${widget.targetFormat} file',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
  
  // Handling custom validation logic from original file if needed, 
  // but mixin's pickFile usually handles extensions well. 
  // The original had a fallback check for jpg/jpeg loose matching. 
  // ConversionMixin relies on FilePicker's allowedExtensions which works well.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.toolName,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
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
                ConversionHeaderCardWidget(
                  title: widget.toolName,
                  description: 'Convert ${widget.sourceFormat} files to ${widget.targetFormat} format.',
                  iconTarget: Icons.transform, // Or dynamic based on type?
                  iconSource: Icons.image,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'custom'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select ${widget.sourceFormat} File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.image, // Generic image icon
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: '.${widget.targetExtension} extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to ${widget.targetFormat}',
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
                    Text(
                      '${widget.targetFormat} Ready',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      result.fileName,
                      style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 12),
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
