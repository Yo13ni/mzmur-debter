class Poem {
  final String? id;
  final String title;
  final String content;
  final String category;
  final String? categoryId;

  Poem({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'category_id': categoryId,
    };
  }

  factory Poem.fromMap(Map<String, dynamic> map) {
    return Poem(
      id: map['id']?.toString(),
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? '',
      categoryId: map['category_id'] as String?,
    );
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['categoryName'] as String? ??
          json['category'] as String? ??
          '',
      categoryId: json['categoryId'] as String?,
    );
  }
}
