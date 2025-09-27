import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/news_article.dart';
import '../providers/feed_provider.dart';
import '../widgets/article_card.dart';
import 'article_webview_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onLocaleChanged, required this.currentLocale});

  final ValueChanged<Locale> onLocaleChanged;
  final Locale currentLocale;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Consumer<FeedProvider>(
      builder: (context, provider, _) {
        final sortedTopics = provider.sources.map((s) => s.topic).toSet().toList()..sort();
        final selectedTopic = provider.selectedTopic;
        return Scaffold(
          appBar: AppBar(
            title: Text(loc.translate('appTitle')),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.refresh(force: true),
                tooltip: loc.translate('refresh'),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(
                        onLocaleChanged: widget.onLocaleChanged,
                        currentLocale: widget.currentLocale,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          decoration: InputDecoration(labelText: loc.translate('selectTopic')),
                          value: selectedTopic,
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(loc.translate('allTopics')),
                            ),
                            ...sortedTopics.map(
                              (topic) => DropdownMenuItem<String?>(
                                value: topic,
                                child: Text(topic),
                              ),
                            ),
                          ],
                          onChanged: (value) => provider.selectTopic(value),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 96,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: provider.sources.map((source) {
                          final selected = provider.selectedSourceIds.contains(source.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text(source.name),
                              selected: selected,
                              onSelected: (value) => provider.toggleSource(source.id, value),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.refresh(force: true),
                    child: provider.isLoading && provider.articles.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : provider.hasError
                            ? _ErrorState(onRetry: () => provider.refresh(force: true))
                            : provider.articles.isEmpty
                                ? _EmptyState(message: loc.translate('noArticles'))
                                : ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemCount: provider.articles.length,
                                    itemBuilder: (context, index) {
                                      final article = provider.articles[index];
                                      return ArticleCard(
                                        article: article,
                                        onTap: () => _openArticle(article),
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openArticle(NewsArticle article) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleWebViewPage(article: article),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, size: 48),
                const SizedBox(height: 12),
                Text(loc.translate('noArticles')),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(loc.translate('retry')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Center(child: Text(message)),
        ),
      ],
    );
  }
}
