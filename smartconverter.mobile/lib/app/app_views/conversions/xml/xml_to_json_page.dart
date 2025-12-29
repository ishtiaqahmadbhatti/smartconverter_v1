import '../../../app_modules/imports_module.dart';

class XmlToJsonFromXmlCategoryPage extends StatefulWidget {
  const XmlToJsonFromXmlCategoryPage({super.key});

  @override
  State<XmlToJsonFromXmlCategoryPage> createState() => _XmlToJsonFromXmlCategoryPageState();
}

class _XmlToJsonFromXmlCategoryPageState extends State<XmlToJsonFromXmlCategoryPage> with AdHelper, ConversionMixin {
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select an XML file to begin.',
  );

  @override
  final TextEditingController fileNameController = TextEditingController();

  final TextEditingController _jsonPreviewController = TextEditingController();

  @override
  String get fileTypeLabel => 'XML';

  @override
  List<String> get allowedExtensions => ['xml'];

  @override
  String get conversionToolName => 'XmlToJson';

  @override
  Future<Directory> get saveDirectory => FileManager.getXmlToJsonDirectory();

  @override
  void dispose() {
    _jsonPreviewController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    return service.convertXmlToJson(
      file!,
      outputFilename: outputName,
    );
  }

  Future<void> _copyJsonContent() async {
    if (_jsonPreviewController.text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _jsonPreviewController.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON copied to clipboard'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('XML to JSON', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const ConversionHeaderCardWidget(
                        title: 'Convert XML to JSON',
                        description: 'Transform XML data into structured JSON.',
                        sourceIcon: Icons.code,
                        destinationIcon: Icons.data_object,
                      ),
                      const SizedBox(height: 20),
                      ConversionActionButtonWidget(
                        isFileSelected: model.selectedFile != null,
                        onPickFile: pickFile,
                        onReset: resetForNewConversion,
                        isConverting: model.isConverting,
                        buttonText: 'Select XML File',
                      ),
                      if (model.selectedFile != null) ...[
                        const SizedBox(height: 20),
                        ConversionSelectedFileCardWidget(
                          fileName: basename(model.selectedFile!.path),
                          fileSize: formatBytes(model.selectedFile!.lengthSync()),
                          fileIcon: Icons.code,
                        ),
                        const SizedBox(height: 16),
                        ConversionFileNameFieldWidget(
                          controller: fileNameController,
                          suggestedName: model.suggestedBaseName,
                          extensionLabel: '.json extension is added automatically',
                        ),
                        const SizedBox(height: 20),
                        ConversionConvertButtonWidget(
                          isConverting: model.isConverting,
                          onConvert: convert,
                          buttonText: 'Convert to JSON',
                        ),
                      ],
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: getBannerAdWidget(),
    );
  }
}

