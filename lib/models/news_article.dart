import 'package:intl/intl.dart';

class NewsArticle {
  NewsArticle({
    required this.title,
    required this.snippet,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.link,
    required this.feedId,
    required this.topic,
    required this.language,
  });

  final String title;
  final String snippet;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;
  final String link;
  final String feedId;
  final String topic;
  final String language;

  String formattedDate(String locale) {
    return DateFormat.yMMMMd(locale).add_Hm().format(publishedAt.toLocal());
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'snippet': snippet,
        'imageUrl': imageUrl,
        'source': source,
        'publishedAt': publishedAt.toIso8601String(),
        'link': link,
        'feedId': feedId,
        'topic': topic,
        'language': language,
      };

  factory NewsArticle.fromJson(Map<String, dynamic> json) => NewsArticle(
        title: json['title'] as String,
        snippet: json['snippet'] as String,
        imageUrl: json['imageUrl'] as String?,
        source: json['source'] as String,
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        link: json['link'] as String,
        feedId: json['feedId'] as String,
        topic: json['topic'] as String,
        language: json['language'] as String,
      );
}
