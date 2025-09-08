class Notes {
  final String? title;
  final String? content;
  final List<String>? tags;

  Notes({this.title, this.content, this.tags,});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      title: json['title'],
      content: json['content'],
      tags: json['tags'],
    );
  }

  copyWith({
    String? title,
    String? content,
    List<String>? tags,
  }) {
    return Notes(
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
    );
  }
}
