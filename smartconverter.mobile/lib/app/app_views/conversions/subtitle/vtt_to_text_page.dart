import '../../../app_modules/imports_module.dart';

class VttToTextPage extends StatefulWidget {
  const VttToTextPage({super.key});

  @override
  State<VttToTextPage> createState() => _VttToTextPageState();
}

class _VttToTextPageState extends State<VttToTextPage> 
    with AdHelper, SubtitleConversionMixin {
  
  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a VTT file to begin.',
  );

  @override
  String get fileTypeLabel => 'VTT';
  
  @override
  List<String> get allowedExtensions => ['vtt'];
  
  @override
  String get conversionToolName => 'VTT-to-Text';
  
  @override
  Future<Directory> get saveDirectory => FileManager.getVttToTextSubtitleDirectory();

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
  Future<ImageToPdfResult?> performConversion(File file, String? outputName) {
    return service.convertVttToText(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert VTT to Text', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConversionHeaderCardWidget(
                      title: 'VTT to Text',
                      description: 'Convert subtitle captions from .vtt to a plain .txt file',
                      iconSource: Icons.featured_video_outlined,
                      iconTarget: Icons.description_outlined,
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtonWidget(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select VTT File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCardWidget(
                        fileName: basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.featured_video,
                      ),
                      const SizedBox(height: 16),
                      ConversionFileNameFieldWidget(
                        controller: fileNameController,
                      ),
                      const SizedBox(height: 24),
                      ConversionConvertButtonWidget(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        buttonText: 'Convert to Text',
                        isEnabled: !model.isConverting,
                      ),
                      const SizedBox(height: 24),
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
      bottomNavigationBar: buildBannerAd(),
    );
  }
}

