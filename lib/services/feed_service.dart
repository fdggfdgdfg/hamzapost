import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

import '../models/feed_source.dart';
import '../models/news_article.dart';

class FeedService {
  FeedService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  List<FeedSource>? _sources;

  Future<List<FeedSource>> loadSources() async {
    if (_sources != null) {
      return _sources!;
    }
    final jsonString = await rootBundle.loadString('assets/feeds.json');
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    _sources = decoded
        .map((item) => FeedSource.fromJson(item as Map<String, dynamic>))
        .toList();
    return _sources!;
  }

  Future<List<String>> topics() async {
    final sources = await loadSources();
    return sources.map((s) => s.topic).toSet().toList()..sort();
  }

  Future<List<NewsArticle>> fetchArticles({
    Set<String>? sourceIds,
    String? topic,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final sources = await loadSources();
    final filteredSources = sources.where((source) {
      final matchesSource = sourceIds == null || sourceIds.contains(source.id);
      final matchesTopic = topic == null || source.topic == topic;
      return matchesSource && matchesTopic;
    }).toList();

    final articles = <NewsArticle>[];
    for (final source in filteredSources) {
      try {
        final response = await _client
            .get(Uri.parse(source.url))
            .timeout(timeout);
        if (response.statusCode != 200) {
          log('Failed to fetch feed ${source.id}: ${response.statusCode}');
          continue;
        }
        final feed = RssFeed.parse(response.body);
        for (final item in feed.items) {
          final title = item.title?.trim();
          final link = item.link?.trim() ?? item.guid ?? '';
          if (title == null || link.isEmpty) {
            continue;
          }
          final snippet = _sanitizeSnippet(item.description ?? item.content?.value ?? '');
          final sourceName = item.source?.value?.trim() ?? source.name;
          final imageUrl = item.media?.contents
                  .firstWhereOrNull((content) => content.url != null)
                  ?.url ??
              item.media?.thumbnails
                  .firstWhereOrNull((thumb) => thumb.url != null)
                  ?.url;
          final pubDate = item.pubDate?.trim();
          DateTime publishedAt;
          if (pubDate != null) {
            publishedAt = DateTime.tryParse(pubDate) ?? DateTime.now();
          } else {
            publishedAt = DateTime.now();
          }
          articles.add(
            NewsArticle(
              title: title,
              snippet: snippet,
              imageUrl: imageUrl,
              source: sourceName,
              publishedAt: publishedAt,
              link: link,
              feedId: source.id,
              topic: source.topic,
              language: source.language,
            ),
          );
        }
      } catch (err, stack) {
        log('Feed parsing error for ${source.id}: $err', stackTrace: stack);
      }
    }

    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return articles;
  }

  String _sanitizeSnippet(String value) {
    final withoutHtml = value
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&[^;]+;'), ' ');
    final condensed = withoutHtml.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (condensed.length <= 200) {
      return condensed;
    }
    return condensed.substring(0, 197).trim() + '…';
  }

  void dispose() {
    _client.close();
  }
}
