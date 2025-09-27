class FeedSource {
  FeedSource({
    required this.id,
    required this.name,
    required this.topic,
    required this.language,
    required this.url,
  });

  final String id;
  final String name;
  final String topic;
  final String language;
  final String url;

  factory FeedSource.fromJson(Map<String, dynamic> json) => FeedSource(
        id: json['id'] as String,
        name: json['name'] as String,
        topic: json['topic'] as String,
        language: json['language'] as String,
        url: json['url'] as String,
      );
}
