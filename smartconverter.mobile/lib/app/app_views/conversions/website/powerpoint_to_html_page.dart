import '../../../app_modules/imports_module.dart';

class PowerPointToHtmlPage extends StatefulWidget {
  const PowerPointToHtmlPage({super.key});

  @override
  State<PowerPointToHtmlPage> createState() => _PowerPointToHtmlPageState();
}

class _PowerPointToHtmlPageState extends State<PowerPointToHtmlPage>
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Select a PowerPoint presentation to begin.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'PowerPoint';

  @override
  List<String> get allowedExtensions => ['ppt', 'pptx'];

  @override
  String get conversionToolName => 'PowerPointToHtml';

  @override
  String get convertingMessage => 'Converting PowerPoint to HTML...';

  @override
  String get successMessage => 'HTML generated successfully!';

  @override
  String get targetExtension => '.html';

  @override
  Future<Directory> get saveDirectory => FileManager.getPowerPointToHtmlDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    fileNameController.removeListener(handleFileNameChange);
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('Please select a PowerPoint file');
    
    return await service.convertPowerPointToHtml(
      file,
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
          'PowerPoint to HTML',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  title: 'Convert PPT to HTML',
                  description: 'Convert PowerPoint presentations (.ppt, .pptx) to HTML format',
                  sourceIcon: Icons.slideshow_outlined,
                  destinationIcon: Icons.code,
                ),
                const SizedBox(height: 20),
                
                if (model.selectedFile == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: model.isConverting ? null : pickFile,
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('Select PPT File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  ConversionFileCardWidget(
                    fileTypeLabel: fileTypeLabel,
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    onRemove: () => resetForNewConversion(customStatus: 'Select a PowerPoint presentation to begin.'),
                  ),
                ],

                const SizedBox(height: 16),
                
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.html extension is added automatically',
                ),
                
                const SizedBox(height: 20),
                
                ConversionConvertButtonWidget(label: 'Convert to HTML',
                  icon: Icons.transform,
                  onPressed: convert,
                  isLoading: model.isConverting,
                ),
                
                const SizedBox(height: 16),
                
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  ConversionFileSaveCardWidget(
                    fileName: model.conversionResult!.fileName,
                    isSaving: model.isSaving,
                    onSave: saveResult,
                    title: 'HTML File Ready',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: getBannerAdWidget(),
    );
  }
}

