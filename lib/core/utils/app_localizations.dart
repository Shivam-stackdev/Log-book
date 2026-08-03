import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Mesh Management',
      'welcome': 'Welcome, Quartermaster',
      'total_items': 'Total Items',
      'low_stock': 'Low Stock',
      'daily_deduction': 'Daily Deduction',
      'monthly_cost': 'Monthly Cost',
      'quick_actions': 'Quick Actions',
      'stock_management': 'Stock Management',
      'record_daily_usage': 'Record daily usage',
      'officer_party': 'Officer Party',
      'ocr_bill_scan': 'Bill Scan',
      'import_bills': 'Import bills automatically',
      'home': 'Home',
      'reports': 'Reports',
      'history': 'History',
      'settings': 'Settings',
      'bill_scanner': 'Bill Scanner',
      'scan_bill_hint': 'Scan a bill to extract items automatically',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'save_bill': 'Save Bill',
      'items_detected': 'items detected',
      'total': 'Total',
      'bill_category': 'Bill Category',
      'bill_category_hint': 'What is this bill for?',
      'officers_party': 'Officers Party',
      'daily_deduction_cat': 'Daily Deduction',
      'monthly_stock': 'Per Month Stock Fill',
      'record_consumption': 'Record Consumption',
      'select_item': 'Select Item',
      'quantity': 'Quantity',
      'reason': 'Reason / Event',
      'confirm_deduction': 'Record Deduction',
      'insufficient_stock': 'Insufficient stock',
      'deduction_success': 'Deduction recorded successfully',
      'deduction_duplicate': 'Daily deduction for this date has already been completed.',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi (हिन्दी)',
      'ai_settings': 'AI Integration',
      'ai_api_key': 'OpenAI API Key',
      'ai_enabled': 'Enable AI',
      'add': 'Add',
      'cancel': 'Cancel',
      'items': 'Items',
      'party_items': 'Party Items',
      'add_party_item': 'Add Item to Party',
    },
    'hi': {
      'app_title': 'मेश मैनेजमेंट',
      'welcome': 'स्वागत है, क्वार्टरमास्टर',
      'total_items': 'कुल आइटम',
      'low_stock': 'कम स्टॉक',
      'daily_deduction': 'रोज़ाना कटौती',
      'monthly_cost': 'मासिक खर्च',
      'quick_actions': 'त्वरित कार्य',
      'stock_management': 'स्टॉक प्रबंधन',
      'record_daily_usage': 'रोज़ाना उपयोग दर्ज करें',
      'officer_party': 'अफ़सरों की पार्टी',
      'ocr_bill_scan': 'बिल स्कैन',
      'import_bills': 'बिल स्वचालित इम्पोर्ट करें',
      'home': 'होम',
      'reports': 'रिपोर्ट',
      'history': 'इतिहास',
      'settings': 'सेटिंग्स',
      'bill_scanner': 'बिल स्कैनर',
      'scan_bill_hint': 'बिल स्कैन करें - आइटम स्वचालित निकालें',
      'camera': 'कैमरा',
      'gallery': 'गैलरी',
      'save_bill': 'बिल सेव करें',
      'items_detected': 'आइटम मिले',
      'total': 'कुल',
      'bill_category': 'बिल श्रेणी',
      'bill_category_hint': 'यह बिल किस चीज़ के लिए है?',
      'officers_party': 'अफ़सरों की पार्टी',
      'daily_deduction_cat': 'रोज़ाना कटौती',
      'monthly_stock': 'मासिक स्टॉक भरना',
      'record_consumption': 'उपभोग दर्ज करें',
      'select_item': 'आइटम चुनें',
      'quantity': 'मात्रा',
      'reason': 'कारण / घटना',
      'confirm_deduction': 'कटौती दर्ज करें',
      'insufficient_stock': 'अपर्याप्त स्टॉक',
      'deduction_success': 'कटौती सफलतापूर्वक दर्ज',
      'deduction_duplicate': 'इस तारीख की कटौती पहले ही दर्ज हो चुकी है।',
      'language': 'भाषा',
      'english': 'English',
      'hindi': 'हिन्दी',
      'ai_settings': 'AI एकीकरण',
      'ai_api_key': 'OpenAI API Key',
      'ai_enabled': 'AI सक्षम करें',
      'add': 'जोड़ें',
      'cancel': 'रद्द करें',
      'items': 'आइटम',
      'party_items': 'पार्टी आइटम',
      'add_party_item': 'पार्टी में आइटम जोड़ें',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
