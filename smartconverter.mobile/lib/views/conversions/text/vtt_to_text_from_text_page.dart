import 'package:path/path.dart' as p;

import '../conversion_imports.dart';

class VttToTextFromTextPage extends StatefulWidget {
  const VttToTextFromTextPage({super.key});

  @override
  State<VttToTextFromTextPage> createState() => _VttToTextFromTextPageState();
}

class _VttToTextFromTextPageState extends State<VttToTextFromTextPage>
    with AdHelper, TextConversionMixin {

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
  List<String> get allowedExtensions => []; // Empty to trigger FileType.any in Service
  
  @override
  String get conversionToolName => 'VTT-to-Text-Text'; 
  
  @override
  Future<Directory> get saveDirectory => FileManager.getVttToTextDirectory();

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
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Convert VTT to Text', style: TextStyle(color: AppColors.textPrimary)),
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
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConversionHeaderCard(
                      title: 'VTT to Text',
                      description: 'Extract captions from VTT subtitles and save as .txt',
                      iconSource: Icons.insert_drive_file,
                      iconTarget: Icons.text_fields,
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtons(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select VTT File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCard(
                        fileName: p.basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.insert_drive_file,
                      ),
                      const SizedBox(height: 16),
                      ConversionFileNameField(
                        controller: fileNameController,
                        hintText: model.suggestedBaseName ?? 'converted_document',
                      ),
                      const SizedBox(height: 24),
                      ConversionConvertButton(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        isEnabled: model.selectedFile != null && !model.isConverting,
                      ),
                      const SizedBox(height: 24),
                    ],

                    ConversionStatusDisplay(
                        message: model.statusMessage,
                        isConverting: model.isConverting,
                        isSuccess: model.conversionResult != null,
                    ),
                    
                    if (model.conversionResult != null) ...[
                      const SizedBox(height: 20),
                      if (model.savedFilePath == null)
                        ConversionResultSaveCard(
                          fileName: model.conversionResult!.fileName,
                          isSaving: model.isSaving,
                          onSave: saveResult,
                          title: 'Text File Ready', 
                        )
                      else
                        PersistentResultCard(
                            savedFilePath: model.savedFilePath!,
                            onShare: shareTextFile,
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
