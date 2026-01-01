import '../../../app_modules/imports_module.dart';

class OxpsToPdfPage extends StatefulWidget {
  const OxpsToPdfPage({super.key});

  @override
  State<OxpsToPdfPage> createState() => _OxpsToPdfPageState();
}

class _OxpsToPdfPageState extends State<OxpsToPdfPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an OXPS file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'OXPS to PDF';

  @override
  String get fileTypeLabel => 'OXPS';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['oxps', 'xps'];

  @override
  Future<Directory> get saveDirectory => FileManager.getOxpsToPdfDirectory();

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    // Feature not yet implemented in backend
    await Future.delayed(const Duration(milliseconds: 500));
    throw UnimplementedError('This feature is coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Convert OXPS to PDF',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                const ConversionHeaderCardWidget(
                  title: 'OXPS to PDF',
                  description: 'Convert OXPS documents to PDF format.',
                  iconTarget: Icons.picture_as_pdf,
                  iconSource: Icons.description_outlined,
                ),
                const SizedBox(height: 20),
                const Card(
                  color: AppColors.backgroundSurface,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'This feature is currently under maintenance and will be available in a future update.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Disabled UI
                ConversionActionButtonWidget(
                  onPickFile: () {},
                  isFileSelected: false,
                  isConverting: false,
                  onReset: () {},
                  buttonText: 'Select OXPS File',
                ),
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
