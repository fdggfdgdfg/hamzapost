import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/feed_source.dart';
import '../models/news_article.dart';
import '../services/cache_service.dart';
import '../services/feed_service.dart';
import '../services/notification_service.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider(
    this._feedService,
    this._cacheService,
    this._notificationService,
  );

  final FeedService _feedService;
  final CacheService _cacheService;
  final NotificationService _notificationService;

  List<FeedSource> _sources = [];
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _initialized = false;
  final Set<String> _selectedSourceIds = {};
  String? _selectedTopic;
  bool _notificationsEnabled = false;
  final Set<String> _keywords = {};
  final Set<String> _notifiedLinks = {};

  List<FeedSource> get sources => _sources;
  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  Set<String> get selectedSourceIds => _selectedSourceIds;
  String? get selectedTopic => _selectedTopic;
  bool get notificationsEnabled => _notificationsEnabled;
  List<String> get keywords => _keywords.toList(growable: false);

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _sources = await _feedService.loadSources();
    if (_selectedSourceIds.isEmpty) {
      _selectedSourceIds.addAll(_sources.map((s) => s.id));
    }
    final cached = await _cacheService.loadArticles(_cacheKey());
    if (cached != null) {
      _articles = cached;
      notifyListeners();
    }
    await refresh();
  }

  Future<void> refresh({bool force = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      if (!force) {
        final cached = await _cacheService.loadArticles(_cacheKey());
        if (cached != null) {
          _articles = cached;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      final result = await _feedService.fetchArticles(
        sourceIds: _selectedSourceIds,
        topic: _selectedTopic,
      );
      _articles = result;
      await _cacheService.saveArticles(_cacheKey(), result);
      await _maybeDispatchNotifications(result);
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _maybeDispatchNotifications(List<NewsArticle> articles) async {
    if (!_notificationsEnabled || _keywords.isEmpty) {
      return;
    }
    final lowerKeywords = _keywords.map((e) => e.toLowerCase()).toList();
    for (final article in articles.take(20)) {
      if (_notifiedLinks.contains(article.link)) {
        continue;
      }
      final haystack = '${article.title} ${article.snippet}'.toLowerCase();
      final matches = lowerKeywords.any((keyword) => haystack.contains(keyword));
      if (matches) {
        _notifiedLinks.add(article.link);
        await _notificationService.showBreakingNews(article);
      }
    }
  }

  Future<void> toggleSource(String id, bool selected) async {
    if (selected) {
      _selectedSourceIds.add(id);
    } else {
      _selectedSourceIds.remove(id);
    }
    await refresh(force: true);
  }

  Future<void> selectTopic(String? topic) async {
    _selectedTopic = topic;
    await refresh(force: true);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    if (value) {
      await _notificationService.requestPermission();
    }
    notifyListeners();
  }

  Future<void> setKeywords(List<String> keywords) async {
    _keywords
      ..clear()
      ..addAll(keywords.where((element) => element.trim().isNotEmpty));
    _notifiedLinks.clear();
    notifyListeners();
  }

  String _cacheKey() {
    final sortedSources = _selectedSourceIds.toList()..sort();
    return '${sortedSources.join('-')}|${_selectedTopic ?? 'all'}';
  }
}
