import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(Localizations.localeOf(context));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome back',
      'manage': 'Manage your campus services through one smart and modern experience.',
      'services': 'Services',
      'choose': 'Choose a service to continue.',
      'chatbot': 'AI Chatbot',
      'chatbot_desc': 'Ask questions and get instant campus support.',
      'library': 'Library',
      'library_desc': 'Browse books, featured titles, and categories.',
      'rules': 'Rules',
      'rules_desc': 'View categorized academic and campus policies.',
      'bus': 'Bus System',
      'bus_desc': 'Track routes, ETA, and transport status.',
      'logout': 'Logout',
      'language': 'Language',
    },
    'ar': {
      'welcome': 'أهلاً بعودتك',
      'manage': 'إدارة خدماتك الجامعية من خلال تجربة ذكية وعصرية.',
      'services': 'الخدمات',
      'choose': 'اختر خدمة للمتابعة',
      'chatbot': 'المساعد الذكي',
      'chatbot_desc': 'اطرح الأسئلة واحصل على دعم فوري',
      'library': 'المكتبة',
      'library_desc': 'تصفح الكتب والتصنيفات',
      'rules': 'القوانين',
      'rules_desc': 'عرض القوانين الجامعية',
      'bus': 'نظام الباصات',
      'bus_desc': 'تتبع المسارات ووقت الوصول',
      'logout': 'تسجيل الخروج',
      'language': 'اللغة',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}
