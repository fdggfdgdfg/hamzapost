# HamzaPost

HamzaPost is a Flutter-based news reader that aggregates Moroccan headlines from fifty curated Google News RSS feeds. The application keeps the user interface simple, supports Arabic (RTL), French, and English, and respects the ownership of each content source.

## Features

- 📰 Aggregates Moroccan news from 50 Google News RSS feeds defined in `assets/feeds.json`.
- ⚡ Local cache for 60 minutes with a manual refresh button.
- 🌐 Multilingual UI (Arabic, French, English) with RTL support for Arabic.
- 📱 Opens original articles in an in-app WebView.
- 🔔 Optional local notifications for breaking news keywords.
- 🧭 Filter articles by source or topic tags.
- 📄 Privacy policy and legal disclaimer pages.
- 🔒 No personal data collection and no full article republishing (only snippets).

## Getting Started

1. Install Flutter (3.x recommended) and run `flutter pub get` in the project directory.
2. Run the app with `flutter run` on an emulator or a physical device.

## Modifying RSS Sources

1. Open `assets/feeds.json`. Each entry has the following structure:
   ```json
   {
     "id": "hespress",
     "name": "Hespress",
     "topic": "morocco",
     "language": "ar",
     "url": "https://news.google.com/rss/search?q=site:hespress.com&hl=ar&gl=MA&ceid=MA:ar"
   }
   ```
2. Add, remove, or update feed entries as needed. Ensure each `id` is unique and the `url` is a valid Google News RSS feed URL.
3. Rebuild the app to include the updated feed list.

## Adding New Topics

- Use the `topic` field in `feeds.json` to categorize feeds (e.g., `morocco`, `sahara`, `algeria`, `economy`, `sports`).
- The settings page reads these topics to offer filtering options.

## Localization

- Strings are defined in `lib/l10n/app_localizations.dart` and grouped by locale.
- To add a new language, extend the `_localizedValues` map with translated strings and add the locale to `supportedLocales` in `main.dart`.

## Privacy & Legal

- The app displays a privacy policy and legal disclaimer on first launch and via the settings page.
- The app does not collect, store, or transmit personal user data.
- Only excerpts from the RSS feeds are shown; users must open the original article to read the full content.

## Notifications

- Breaking news notifications are managed locally by `NotificationService`.
- Users can configure keywords in the settings page. The service scans fetched articles and triggers notifications when titles or descriptions contain those keywords.

## Troubleshooting

- If feeds do not load, check network connectivity or refresh manually.
- RSS parsing errors are reported in the console logs; ensure the feed URLs are reachable.

## License

This project is provided as-is for demonstration purposes.
