import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'pages/home_page.dart';
import 'providers/feed_provider.dart';
import 'services/cache_service.dart';
import 'services/feed_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cacheService = await CacheService.create();
  final notificationService = await NotificationService.create();
  final feedService = FeedService();
  runApp(HamzaPostApp(
    cacheService: cacheService,
    notificationService: notificationService,
    feedService: feedService,
  ));
}

class HamzaPostApp extends StatefulWidget {
  const HamzaPostApp({
    super.key,
    required this.cacheService,
    required this.notificationService,
    required this.feedService,
  });

  final CacheService cacheService;
  final NotificationService notificationService;
  final FeedService feedService;

  @override
  State<HamzaPostApp> createState() => _HamzaPostAppState();
}

class _HamzaPostAppState extends State<HamzaPostApp> {
  Locale _locale = const Locale('ar');

  void _updateLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FeedProvider(
            widget.feedService,
            widget.cacheService,
            widget.notificationService,
          )..initialize(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        onGenerateTitle: (context) => AppLocalizations.of(context).translate('appTitle'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1264A3)),
          useMaterial3: true,
          cardTheme: const CardTheme(elevation: 1.5),
        ),
        home: HomePage(onLocaleChanged: _updateLocale, currentLocale: _locale),
      ),
    );
  }
}
