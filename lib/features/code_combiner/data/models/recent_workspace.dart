class RecentWorkspace {
  final String path;
  final String name;
  final DateTime lastAccessed;
  final bool isFavorite;
  
  RecentWorkspace({
    required this.path,
    required this.name,
    required this.lastAccessed,
    required this.isFavorite,
  });
  
  RecentWorkspace copyWith({
    String? path,
    String? name,
    DateTime? lastAccessed,
    bool? isFavorite,
  }) {
    return RecentWorkspace(
      path: path ?? this.path,
      name: name ?? this.name,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}