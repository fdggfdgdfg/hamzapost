import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'appTitle': 'حمزة بوست',
      'filters': 'التصنيفات',
      'allTopics': 'كل المواضيع',
      'sources': 'المصادر',
      'refresh': 'تحديث',
      'settings': 'الإعدادات',
      'selectLanguage': 'اختر اللغة',
      'selectSources': 'اختر المصادر',
      'selectTopic': 'اختر الموضوع',
      'notifications': 'الإشعارات',
      'notificationKeywords': 'الكلمات المفتاحية للأخبار العاجلة',
      'addKeywordHint': 'أدخل كلمة واضغط إضافة',
      'privacyPolicy': 'سياسة الخصوصية',
      'legalNotice': 'تنبيه قانوني',
      'noArticles': 'لا توجد مقالات متاحة حاليًا.',
      'retry': 'إعادة المحاولة',
      'privacyContent':
          'لا يجمع التطبيق أي بيانات شخصية. يتم تخزين الإعدادات محليًا فقط.',
      'legalContent':
          'جميع الحقوق محفوظة لمصادر الأخبار الأصلية. يتم عرض مقتطفات وروابط فقط.',
      'add': 'إضافة',
      'keywordListEmpty': 'لم يتم تحديد كلمات.',
      'breakingNews': 'أخبار عاجلة',
    },
    'fr': {
      'appTitle': 'HamzaPost',
      'filters': 'Filtres',
      'allTopics': 'Tous les thèmes',
      'sources': 'Sources',
      'refresh': 'Actualiser',
      'settings': 'Paramètres',
      'selectLanguage': 'Choisir la langue',
      'selectSources': 'Choisir les sources',
      'selectTopic': 'Choisir un thème',
      'notifications': 'Notifications',
      'notificationKeywords': 'Mots-clés pour les alertes',
      'addKeywordHint': 'Saisir un mot puis ajouter',
      'privacyPolicy': 'Politique de confidentialité',
      'legalNotice': 'Mention légale',
      'noArticles': "Aucun article n'est disponible pour le moment.",
      'retry': 'Réessayer',
      'privacyContent':
          "L’application ne collecte aucune donnée personnelle. Les préférences sont stockées localement seulement.",
      'legalContent':
          'Tout le contenu appartient à ses sources originales. Seuls des extraits et des liens sont affichés.',
      'add': 'Ajouter',
      'keywordListEmpty': 'Aucun mot-clé.',
      'breakingNews': 'Dernière minute',
    },
    'en': {
      'appTitle': 'HamzaPost',
      'filters': 'Filters',
      'allTopics': 'All topics',
      'sources': 'Sources',
      'refresh': 'Refresh',
      'settings': 'Settings',
      'selectLanguage': 'Choose language',
      'selectSources': 'Choose sources',
      'selectTopic': 'Choose topic',
      'notifications': 'Notifications',
      'notificationKeywords': 'Keywords for breaking news alerts',
      'addKeywordHint': 'Enter a word then add',
      'privacyPolicy': 'Privacy Policy',
      'legalNotice': 'Legal Notice',
      'noArticles': 'No articles available right now.',
      'retry': 'Retry',
      'privacyContent':
          'The app does not collect personal data. Preferences are stored locally only.',
      'legalContent':
          'All content belongs to its original sources. Only excerpts and links are displayed.',
      'add': 'Add',
      'keywordListEmpty': 'No keywords configured.',
      'breakingNews': 'Breaking News',
    },
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('ar'),
    Locale('fr'),
    Locale('en'),
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations._localizedValues.keys.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
