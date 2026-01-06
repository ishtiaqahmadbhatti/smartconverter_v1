import '../../../app_modules/imports_module.dart';
import 'package:dio/dio.dart';

class GetAudioInfoPage extends StatefulWidget {
  const GetAudioInfoPage({super.key});

  @override
  State<GetAudioInfoPage> createState() => _GetAudioInfoPageState();
}

class _GetAudioInfoPageState extends State<GetAudioInfoPage> with AdHelper {
  File? _selectedFile;
  Map<String, dynamic>? _info;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'wma', 'm4a', 'mp4'],
    );

    if (result != null) {
       setState(() {
         _selectedFile = File(result.files.single.path!);
         _info = null;
         _errorMessage = null;
       });
       _fetchInfo();
    }
  }

  Future<void> _fetchInfo() async {
    if (_selectedFile == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path),
      });

      final response = await dio.post(
        '${await ApiConfig.baseUrl}${ApiConfig.audioInfoEndpoint}',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _info = response.data['audio_info'];
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to get info';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _info = null;
      _errorMessage = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Get Audio Info', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.textPrimary, onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Get Audio Info',
                  description: 'View detailed technical metadata for any audio file.',
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 20),

                ConversionActionButtonWidget(
                  onPickFile: _pickFile,
                  isFileSelected: _selectedFile != null,
                  isConverting: _isLoading,
                  onReset: _reset,
                  buttonText: 'Select Audio File',
                  icon: Icons.search,
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),

                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_selectedFile != null && !_isLoading && _info == null && _errorMessage == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ConversionSelectedFileCardWidget(
                      fileName: basename(_selectedFile!.path),
                      fileSize: _getSafeFileSize(_selectedFile!),
                      fileIcon: Icons.audiotrack,
                      onRemove: _reset,
                    ),
                  ),

                if (_info != null) ...[
                   const SizedBox(height: 20),
                   Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description, color: AppColors.primaryBlue),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              'File: ${basename(_selectedFile!.path)}',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )),
                          ],
                        ),
                        const Divider(color: AppColors.textSecondary, height: 24),
                        _buildInfoList(),
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

  Widget _buildInfoList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _info!.length,
      separatorBuilder: (ctx, i) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        final key = _info!.keys.elementAt(index);
        final value = _info![key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatKey(key),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.toString(),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((str) => 
      str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : ''
    ).join(' ');
  }

  String _getSafeFileSize(File file) {
    try {
      if (!file.existsSync()) return 'File not found';
      return _formatBytes(file.lengthSync());
    } catch (e) {
      return 'Unknown size';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }
}
