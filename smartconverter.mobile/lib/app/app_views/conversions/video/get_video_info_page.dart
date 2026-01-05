import '../../../app_modules/imports_module.dart';

class GetVideoInfoPage extends StatefulWidget {
  const GetVideoInfoPage({super.key});

  @override
  State<GetVideoInfoPage> createState() => _GetVideoInfoPageState();
}

class _GetVideoInfoPageState extends State<GetVideoInfoPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a video file to get information.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();
  
  Map<String, dynamic>? _videoInfo;
  bool _isLoadingInfo = false;

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Get Video Info';

  @override
  String get fileTypeLabel => 'Video';

  @override
  String get targetExtension => ''; // Not used

  @override
  List<String> get allowedExtensions => ['mp4', 'mov', 'mkv', 'avi', 'flv', 'wmv', 'webm', '3gp', 'm4v'];

  @override
  Future<Directory> get saveDirectory => FileManager.getGetVideoInfoDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    // Not used for this page as we use _getVideoInfo directly
    throw UnimplementedError();
  }

  Future<void> _getVideoInfo() async {
    if (model.selectedFile == null) return;

    setState(() {
      _isLoadingInfo = true;
      model.statusMessage = 'Analyzing video...';
      _videoInfo = null;
    });

    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          model.selectedFile!.path,
          filename: basename(model.selectedFile!.path),
        ),
      });

      final response = await dio.post(
        ApiConfig.videoInfoEndpoint,
        data: formData,
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _videoInfo = response.data['video_info'];
          model.statusMessage = 'Analysis complete!';
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get video info');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => model.statusMessage = 'Failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingInfo = false);
      }
    }
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
                  description: 'Get detailed metadata about your video files.',
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 20),
                
                // File Selection
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: _isLoadingInfo,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Video File',
                ),
                const SizedBox(height: 16),

                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.movie,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 20),

                if (model.selectedFile != null) ...[
                  // Custom Action Button for Info
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingInfo ? null : _getVideoInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoadingInfo
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                              ),
                            )
                          : const Text(
                              'Get Info',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],

                if (model.statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    model.statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: model.statusMessage.contains('Error') || model.statusMessage.contains('Failed') 
                          ? Colors.red 
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                
                // Info Result
                if (_videoInfo != null) ...[
                   const SizedBox(height: 20),
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Information',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._videoInfo!.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatKey(entry.key),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.value.toString(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
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

  String _formatKey(String key) {
    return key.split('_').map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' ');
  }
}
