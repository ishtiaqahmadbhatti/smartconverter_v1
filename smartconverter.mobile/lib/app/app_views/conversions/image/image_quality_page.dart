import '../../../app_modules/imports_module.dart';


class ImageQualityPage extends StatefulWidget {
  const ImageQualityPage({super.key});

  @override
  State<ImageQualityPage> createState() => _ImageQualityPageState();
}

class _ImageQualityPageState extends State<ImageQualityPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an image to adjust quality.');

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
                  title: 'Image Quality',
                  description: 'Adjust the quality of your image files.',
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
                  const Text('Quality', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  Slider(
                    value: _quality,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: _quality.round().toString(),
                    onChanged: (val) {
                      setState(() => _quality = val);
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                  Center(
                    child: Text(
                      '${_quality.round()}%',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: '.jpg extension used',
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
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'Prioritized Image Ready',
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
}

