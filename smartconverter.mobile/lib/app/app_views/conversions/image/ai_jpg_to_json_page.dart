import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

class AiJpgToJsonPage extends StatefulWidget {
  const AiJpgToJsonPage({super.key});

  @override
  State<AiJpgToJsonPage> createState() => _AiJpgToJsonPageState();
}

class _AiJpgToJsonPageState extends State<AiJpgToJsonPage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(
      statusMessage: 'Select a JPG file to begin.');

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
    // Handled by mixin if needed
  }

  // Mixin overrides
  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'AI JPG to JSON';

  @override
  String get fileTypeLabel => 'JPG';

  @override
  String get targetExtension => 'json';

  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg'];

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);

    final toolDir = Directory('${imageRoot.path}/ai-jpg-to-json');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<AiImageToJsonResult?> performConversion(File? file,
      String? outputName) async {
    if (file == null) throw Exception('File is null');

    // Ad check
    final adWatched = await showRewardedAdGate(toolName: 'AI JPG-to-JSON');
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.convertAiJpgToJson(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI JPG to JSON',
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
                  title: 'AI JPG to JSON',
                  description: 'Extract structured data from JPG images using AI.',
                  iconTarget: Icons.data_object,
                  iconSource: Icons.smart_toy_outlined,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'custom'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select JPG File',
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
                    extensionLabel: '.json extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to JSON',
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
                      title: 'JSON File Ready',
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