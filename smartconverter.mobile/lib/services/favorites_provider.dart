import '../app_modules/imports_module.dart';

class FavoriteTool {
  final String categoryId;
  final String toolName;
  final int iconCodePoint;
  final String iconFontFamily;

  FavoriteTool({
    required this.categoryId,
    required this.toolName,
    required this.iconCodePoint,
    required this.iconFontFamily,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'toolName': toolName,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
      };

  factory FavoriteTool.fromJson(Map<String, dynamic> json) => FavoriteTool(
        categoryId: json['categoryId'],
        toolName: json['toolName'],
        iconCodePoint: json['iconCodePoint'],
        iconFontFamily: json['iconFontFamily'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteTool &&
          other.categoryId == categoryId &&
          other.toolName == toolName;

  @override
  int get hashCode => categoryId.hashCode ^ toolName.hashCode;
}

class FavoritesProvider extends ChangeNotifier {
  static const String _storageKey = 'favorite_tools';
  List<FavoriteTool> _favorites = [];
  bool _isInitialized = false;

  List<FavoriteTool> get favorites => _favorites;
  bool get isInitialized => _isInitialized;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString(_storageKey);
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        _favorites = decoded.map((item) => FavoriteTool.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite({
    required String categoryId,
    required String toolName,
    required IconData categoryIcon,
  }) async {
    final tool = FavoriteTool(
      categoryId: categoryId,
      toolName: toolName,
      iconCodePoint: categoryIcon.codePoint,
      iconFontFamily: categoryIcon.fontFamily ?? 'MaterialIcons',
    );

    if (_favorites.contains(tool)) {
      _favorites.remove(tool);
    } else {
      _favorites.add(tool);
    }

    notifyListeners();
    await _saveFavorites();
  }

  bool isFavorite(String categoryId, String toolName) {
    return _favorites.any((t) => t.categoryId == categoryId && t.toolName == toolName);
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_favorites.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
}
