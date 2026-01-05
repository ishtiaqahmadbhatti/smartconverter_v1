import '../../../app_modules/imports_module.dart';

class MovToMp4Page extends StatefulWidget {
  const MovToMp4Page({super.key});

  @override
  State<MovToMp4Page> createState() => _MovToMp4PageState();
}

class _MovToMp4PageState extends State<MovToMp4Page> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a MOV file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Convert MOV to MP4';

  @override
  String get fileTypeLabel => 'MOV';

  @override
  String get targetExtension => 'mp4';

  @override
  List<String> get allowedExtensions => ['mov'];

  @override
  Future<Directory> get saveDirectory => FileManager.getMovToMp4Directory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
      file,
      outputFilename: outputName,
      endpoint: ApiConfig.videoMovToMp4Endpoint,
      outputExt: targetExtension,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          conversionToolName,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ConversionHeaderCardWidget(
                  title: conversionToolName,
                  description: 'Transform MOV videos into MP4 format.',
                  sourceIcon: Icons.movie_creation_outlined,
                  destinationIcon: Icons.videocam_outlined,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select MOV File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.movie_creation_outlined,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.$targetExtension extension is added automatically',
                  ),
                const SizedBox(height: 20),
                if (model.selectedFile != null)
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to MP4',
                  ),
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
                      title: 'MP4 File Ready',
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
