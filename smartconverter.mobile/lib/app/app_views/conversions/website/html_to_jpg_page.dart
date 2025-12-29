import '../../../app_modules/imports_module.dart';

class HtmlToJpgPage extends StatefulWidget {
  const HtmlToJpgPage({super.key});

  @override
  State<HtmlToJpgPage> createState() => _HtmlToJpgPageState();
}

class _HtmlToJpgPageState extends State<HtmlToJpgPage>
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Select an HTML file to begin.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'HTML';

  @override
  List<String> get allowedExtensions => ['html', 'htm'];

  @override
  String get conversionToolName => 'HtmlToJpg';

  @override
  String get convertingMessage => 'Converting HTML to JPG...';

  @override
  String get successMessage => 'JPG generated successfully!';

  @override
  String get targetExtension => '.jpg';

  @override
  Future<Directory> get saveDirectory => FileManager.getHtmlToJpgDirectory();

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
    if (file == null) throw Exception('Please select an HTML file');
    
    return await service.convertHtmlToJpg(
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
          'HTML to JPG',
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
                  title: 'Convert HTML to JPG',
                  description: 'Convert HTML files (.html, .htm) to JPG images',
                  sourceIcon: Icons.image_outlined,
                  destinationIcon: Icons.image,
                ),
                const SizedBox(height: 20),
                
                if (model.selectedFile == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: model.isConverting ? null : pickFile,
                      icon: const Icon(Icons.file_open_outlined),
                      label: const Text('Select HTML File'),
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
                    onRemove: () => resetForNewConversion(customStatus: 'Select an HTML file to begin.'),
                  ),
                ],

                const SizedBox(height: 16),
                
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.jpg will be added automatically',
                ),
                
                const SizedBox(height: 20),
                
                ConversionConvertButtonWidget(label: 'Convert to JPG',
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
                    title: 'JPG Ready',
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

