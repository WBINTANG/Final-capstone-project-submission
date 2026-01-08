class Book {
  final int? id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int stock;
  final String? coverPhoto;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.stock,
    this.coverPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'stock': stock,
      'cover_photo': coverPhoto,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isbn: map['isbn'],
      category: map['category'],
      stock: map['stock'],
      coverPhoto: map['cover_photo'],
    );
  }
}
