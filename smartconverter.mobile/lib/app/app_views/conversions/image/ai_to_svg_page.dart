import '../../../app_modules/imports_module.dart';


class AiToSvgPage extends StatefulWidget {
  const AiToSvgPage({super.key});

  @override
  State<AiToSvgPage> createState() => _AiToSvgPageState();
}

class _AiToSvgPageState extends State<AiToSvgPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(
      statusMessage: 'Select an AI (Adobe Illustrator) file to begin.');

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
    service.initialize();
  }

  @override
  void dispose() {
    fileNameController.removeListener(handleFileNameChange);
    fileNameController.dispose();
    super.dispose();
  }

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'AI to SVG';

  @override
  String get fileTypeLabel => 'AI';

  @override
  String get targetExtension => 'svg';

  @override
  List<String> get allowedExtensions => ['ai'];

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);

    final toolDir = Directory('${imageRoot.path}/ai-to-svg');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<ImageFormatConversionResult?> performConversion(File? file,
      String? outputName) async {
    if (file == null) throw Exception('File is null');

    // Ad check
    final adWatched = await showRewardedAdGate(toolName: 'AI to SVG');
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.convertImageFormat(
      file: file,
      apiEndpoint: ApiConfig.imageAiToSvgEndpoint,
      targetExtension: 'svg',
      outputFilename: outputName,
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
          'AI to SVG',
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
                  title: 'AI to SVG',
                  description: 'Convert Adobe Illustrator files to Scalable Vector Graphics.',
                  iconTarget: Icons.draw,
                  iconSource: Icons.image_aspect_ratio,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'custom'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select AI File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.image_aspect_ratio, // AI icon analogue
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: '.svg extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to SVG',
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
                      title: 'SVG Ready',
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