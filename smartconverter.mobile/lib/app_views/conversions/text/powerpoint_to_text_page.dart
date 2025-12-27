import '../../../app_modules/imports_module.dart';

class PowerPointToTextPage extends StatefulWidget {
  const PowerPointToTextPage({super.key});
  
  @override
  State<PowerPointToTextPage> createState() => _PowerPointToTextPageState();
}

class _PowerPointToTextPageState extends State<PowerPointToTextPage> 
    with AdHelper, TextConversionMixin {

  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a PowerPoint file (.ppt/.pptx) to begin.',
  );

  @override
  String get fileTypeLabel => 'PowerPoint';
  
  @override
  List<String> get allowedExtensions => ['ppt', 'pptx'];
  
  @override
  String get conversionToolName => 'PowerPoint-to-Text'; 
  
  @override
  Future<Directory> get saveDirectory => FileManager.getPowerpointToTextDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    fileNameController
      ..removeListener(handleFileNameChange)
      ..dispose();
    super.dispose();
  }
  
  @override
  @override
  Future<ImageToPdfResult?> performConversion(File file, String? outputName) {
    return service.convertPowerpointToText(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert PowerPoint to Text', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConversionHeaderCardWidget(
                  title: 'PowerPoint to Text',
                  description: 'Extract text from slides and tables in PowerPoint (.ppt, .pptx) and save as .txt',
                  iconSource: Icons.slideshow,
                  iconTarget: Icons.text_fields,
                ),
                const SizedBox(height: 20),

                ConversionActionButtonWidget(
                  isFileSelected: model.selectedFile != null,
                  onPickFile: pickFile,
                  onReset: resetForNewConversion,
                  isConverting: model.isConverting,
                  buttonText: 'Select PowerPoint File',
                ),
                const SizedBox(height: 16),

                if (model.selectedFile != null) ...[
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.slideshow,
                  ),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    hintText: model.suggestedBaseName ?? 'converted_presentation',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    isConverting: model.isConverting,
                    onConvert: convert,
                    isEnabled: model.selectedFile != null && !model.isConverting,
                  ),
                  const SizedBox(height: 16),
                ],

                ConversionStatusDisplayWidget(
                    message: model.statusMessage,
                    isConverting: model.isConverting,
                    isSuccess: model.conversionResult != null,
                ),
                
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'Text File Ready',
                    )
                  else
                    ConversionResultCardWidget(
                        savedFilePath: model.savedFilePath!,
                        onShare: shareTextFile,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
