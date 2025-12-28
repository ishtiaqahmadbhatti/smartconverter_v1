import '../../../app_modules/imports_module.dart';

class CsvToSrtFromSubtitlePage extends StatefulWidget {
  const CsvToSrtFromSubtitlePage({super.key});

  @override
  State<CsvToSrtFromSubtitlePage> createState() => _CsvToSrtFromSubtitlePageState();
}

class _CsvToSrtFromSubtitlePageState extends State<CsvToSrtFromSubtitlePage> 
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select a CSV file to begin.',
  );

  @override
  String get fileTypeLabel => 'CSV';
  
  @override
  List<String> get allowedExtensions => ['csv'];
  
  @override
  String get conversionToolName => 'CSV-to-SRT';
  
  @override
  Future<Directory> get saveDirectory => FileManager.getCsvToSrtSubtitleDirectory();

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
    return service.convertCsvToSrt(file, outputFilename: outputName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convert CSV to SRT', style: TextStyle(color: AppColors.textPrimary)),
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
                      title: 'CSV to SRT',
                      description: 'Convert subtitle captions from .csv to .srt format',
                      iconSource: Icons.table_chart_outlined,
                      iconTarget: Icons.subtitles_outlined,
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtonWidget(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select CSV File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCardWidget(
                        fileName: basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.table_chart,
                      ),
                      const SizedBox(height: 16),
                      ConversionFileNameFieldWidget(
                        controller: fileNameController,
                      ),
                      const SizedBox(height: 24),
                      ConversionConvertButtonWidget(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        buttonText: 'Convert to SRT',
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
                          title: 'SRT File Ready',
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

