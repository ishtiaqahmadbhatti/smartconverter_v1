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
                  iconTarget: Icons.transform,
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
                    fileIcon: Icons.image,
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
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: '${widget.targetFormat} File Ready',
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
