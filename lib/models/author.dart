class Author {
  final String name;
  final String image;

  Author({required this.name, required this.image});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'],
      image: json['image'],
    );
  }
}
