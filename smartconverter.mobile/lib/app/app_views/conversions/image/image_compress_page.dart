import '../../../app_modules/imports_module.dart';


class ImageCompressPage extends StatefulWidget {
  const ImageCompressPage({super.key});

  @override
  State<ImageCompressPage> createState() => _ImageCompressPageState();
}

class _ImageCompressPageState extends State<ImageCompressPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(
      statusMessage: 'Select an image to compress.');

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
  String get conversionToolName => 'Image Compress';

  @override
  String get fileTypeLabel => 'Image';

  @override
  String get targetExtension =>
      'jpg'; // Uses original or jpg usually, but mainly we want to just save it
  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png', 'webp', 'tiff'];

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);

    final toolDir = Directory('${imageRoot.path}/compress');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<ImageFormatConversionResult?> performConversion(File? file,
      String? outputName) async {
    if (file == null) throw Exception('File is null');

    final adWatched = await showRewardedAdGate(toolName: 'Image Compress');
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.compressImage(file, outputFilename: outputName);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Image Compress',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
                  title: 'Compress Image',
                  description: 'Reduce image file size while maintaining quality.',
                  iconTarget: Icons.compress,
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
                    buttonText: 'Compress Image',
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
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: _getSavingsTitle(),
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
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

  String _getSavingsTitle() {
    final result = model.conversionResult as ImageFormatConversionResult?;
    if (result == null || model.selectedFile == null)
      return 'Compressed Image Ready';

    final originalSize = model.selectedFile!.lengthSync();
    final newSize = result.file.lengthSync();
    if (newSize < originalSize) {
      final percent = ((originalSize - newSize) / originalSize * 100)
          .toStringAsFixed(1);
      return 'Saved $percent%';
    }
    return 'Compressed Image Ready';
  }
}