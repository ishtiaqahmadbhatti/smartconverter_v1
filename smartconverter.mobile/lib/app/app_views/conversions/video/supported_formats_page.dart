import '../../../app_modules/imports_module.dart';

class SupportedFormatsPage extends StatefulWidget {
  const SupportedFormatsPage({super.key});

  @override
  State<SupportedFormatsPage> createState() => _SupportedFormatsPageState();
}

class _SupportedFormatsPageState extends State<SupportedFormatsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _formats;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFormats();
  }

  Future<void> _fetchFormats() async {
    try {
      final apiBaseUrl = await ApiConfig.baseUrl;
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl));
      
      final response = await dio.get(ApiConfig.videoSupportedFormatsEndpoint);

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _formats = response.data['formats'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load formats');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
          'Supported Formats',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading formats',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchFormats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_formats == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            ConversionHeaderCardWidget(
              title: 'Supported Formats',
              description: 'View the list of supported video input and output formats.',
              icon: Icons.list_alt,
            ),
          const SizedBox(height: 20),
          _buildFormatSection('Input Formats', _formats!['input_formats']),
          const SizedBox(height: 24),
          _buildFormatSection('Output Formats', _formats!['output_formats']),
        ],
      ),
    );
  }

  Widget _buildFormatSection(String title, List<dynamic>? formats) {
    if (formats == null || formats.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              child: Text(
                format.toString().toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
