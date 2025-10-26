class ConversionTool {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> supportedFormats;
  final bool isAvailable;
  final String category;

  const ConversionTool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.supportedFormats,
    this.isAvailable = true,
    required this.category,
  });

  factory ConversionTool.fromJson(Map<String, dynamic> json) {
    return ConversionTool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      supportedFormats: List<String>.from(json['supportedFormats'] as List),
      isAvailable: json['isAvailable'] as bool? ?? true,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'supportedFormats': supportedFormats,
      'isAvailable': isAvailable,
      'category': category,
    };
  }

  ConversionTool copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<String>? supportedFormats,
    bool? isAvailable,
    String? category,
  }) {
    return ConversionTool(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      supportedFormats: supportedFormats ?? this.supportedFormats,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionTool && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ConversionTool(id: $id, name: $name, description: $description, isAvailable: $isAvailable)';
  }
}
