class Poem {
  final int? id;
  final String title;
  final String content;
  final String category;

  Poem({this.id, required this.title, required this.content, required this.category});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
    };
  }

  factory Poem.fromMap(Map<String, dynamic> map) {
    return Poem(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
    );
  }
}