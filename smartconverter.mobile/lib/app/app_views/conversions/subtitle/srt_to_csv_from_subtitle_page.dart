import '../../../app_modules/imports_module.dart';

class SrtToCsvFromSubtitlePage extends StatefulWidget {
  const SrtToCsvFromSubtitlePage({super.key});

  @override
  State<SrtToCsvFromSubtitlePage> createState() => _SrtToCsvFromSubtitlePageState();
}

class _SrtToCsvFromSubtitlePageState extends State<SrtToCsvFromSubtitlePage> 
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select an SRT file to begin.',
  );

  @override
  String get fileTypeLabel => 'SRT';
  
  @override
  List<String> get allowedExtensions => ['srt'];
  
  @override
  String get conversionToolName => 'SRT to CSV';
  
  @override
  Future<Directory> get saveDirectory => FileManager.getSrtToCsvSubtitleDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File file, String? outputName) {
    return service.convertSrtToCsv(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SRT to CSV', style: TextStyle(color: AppColors.textPrimary)),
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
                      title: 'Convert SRT to CSV',
                      description: 'Convert subtitle captions from .srt to a structured .csv file',
                      iconSource: Icons.subtitles_outlined, // SRT icon
                      iconTarget: Icons.table_view_outlined, // CSV/Table icon
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtonWidget(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select SRT File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCardWidget(
                        fileName: basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.subtitles,
                      ),
                      const SizedBox(height: 16),

                      ConversionFileNameFieldWidget(
                        controller: fileNameController,
                      ),
                      const SizedBox(height: 24),
                      
                      ConversionConvertButtonWidget(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        buttonText: 'Convert to CSV',
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
                          title: 'Available for Save',
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
