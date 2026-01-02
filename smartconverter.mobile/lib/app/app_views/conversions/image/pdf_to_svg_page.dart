import '../../../app_modules/imports_module.dart';
import 'package:path/path.dart' as p;

class PdfToSvgImagePage extends StatefulWidget {
  final bool useImageCategoryStorage;

  const PdfToSvgImagePage({super.key, this.useImageCategoryStorage = false});

  @override
  State<PdfToSvgImagePage> createState() => _PdfToSvgImagePageState();
}

class _PdfToSvgImagePageState extends State<PdfToSvgImagePage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a PDF file to begin.');

  bool _isSharing = false;
  String? _savedFolderPath;

  @override
  void initState() {
    super.initState();
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
    // handled by mixin/model if needed
  }

  // Mixin overrides
  @override
  ConversionModel get model => _model;
  @override
  TextEditingController get fileNameController => _fileNameController;
  @override
  ConversionService get service => _service;
  @override
  String get conversionToolName => 'PDF to SVG';
  @override
  String get fileTypeLabel => 'PDF';
  @override
  String get targetExtension => 'svg';
  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
    
    final toolDir = Directory('${imageRoot.path}/pdf-to-svg');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<PdfToImagesResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');
    return await service.convertPdfToSvg(file, outputFilename: outputName);
  }

  Future<void> _saveImagesLocally() async {
    final result = model.conversionResult as PdfToImagesResult?;
    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No files to save yet.'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => model.isSaving = true);

    try {
      final baseDir = await saveDirectory;
      String targetFolderName = result.folderName;
      Directory destination = Directory(p.join(baseDir.path, targetFolderName));

      int counter = 1;
      while (await destination.exists()) {
        targetFolderName = '${result.folderName}_$counter';
        destination = Directory(p.join(baseDir.path, targetFolderName));
        counter++;
      }

      await destination.create(recursive: true);

      for (int i = 0; i < result.files.length; i++) {
        final source = result.files[i];
        final fileName = i < result.fileNames.length
            ? result.fileNames[i]
            : p.basename(source.path);
        await source.copy(p.join(destination.path, fileName));
      }

      if (!mounted) return;

      setState(() => _savedFolderPath = destination.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Files saved to: ${destination.path}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save files: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => model.isSaving = false);
    }
  }

  Future<void> _shareImages() async {
    final result = model.conversionResult as PdfToImagesResult?;
    if (result == null || result.files.isEmpty) return;

    setState(() => _isSharing = true);
    try {
      final shareFiles = result.files.map((file) => XFile(file.path)).toList();
      await Share.shareXFiles(
        shareFiles,
        text: 'Converted SVG files for: ${result.folderName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share files: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Convert PDF to SVG',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
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
                const ConversionHeaderCardWidget(
                  title: 'PDF to SVG Files',
                  description: 'Convert each page of your PDF into high-quality SVG files.',
                  iconTarget: Icons.image_outlined,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'custom'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select PDF File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: 'Folder base name (optional)',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to SVG',
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
                  _buildResultsCard(),
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

  Widget _buildResultsCard() {
    final result = model.conversionResult as PdfToImagesResult?;
    if (result == null || result.files.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, color: AppColors.textPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Files Ready',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${result.files.length} SVG files generated',
                      style: TextStyle(color: AppColors.textPrimary.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: model.isSaving ? null : _saveImagesLocally,
                  icon: const Icon(Icons.save_alt),
                  label: Text(model.isSaving ? 'Saving...' : 'Save All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareImages,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.backgroundSurface.withOpacity(0.3),
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}