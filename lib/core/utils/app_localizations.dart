import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Translations map
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Army Mess Inventory',
      'welcome': 'Welcome, Quartermaster',
      'status_operational': 'Mess Inventory Status: Operational',
      'total_items': 'Total Items',
      'low_stock': 'Low Stock',
      'daily_deduction': 'Daily Deduction',
      'monthly_cost': 'Monthly Cost',
      'quick_actions': 'Quick Actions',
      'stock_management': 'Stock Management',
      'manage_inventory': 'Manage inventory items',
      'record_daily_usage': 'Record daily usage',
      'officer_party': 'Officer Party',
      'manage_officer_bills': 'Manage officer bills',
      'ocr_bill_scan': 'OCR Bill Scan',
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
      'officers_party_sub': 'For officers party',
      'daily_deduction_cat': 'Daily Deduction',
      'daily_deduction_sub': 'For daily deduction',
      'monthly_stock': 'Per Month Stock Fill',
      'monthly_stock_sub': 'For monthly stock fill',
      'stock_fill_details': 'Stock Fill Details',
      'supplier_name': 'Supplier Name',
      'deduction_details': 'Deduction Details',
      'reason': 'Reason',
      'select_officer': 'Select Officer',
      'no_officers': 'No officers registered',
      'add_officer': 'Add Officer',
      'register_officer': 'Register Officer',
      'rank': 'Rank',
      'name': 'Name',
      'personal_number': 'Personal Number',
      'record_consumption': 'Record Consumption',
      'select_item': 'Select Item',
      'quantity': 'Quantity',
      'reason_event': 'Reason/Event',
      'confirm_deduction': 'Confirm Deduction',
      'insufficient_stock': 'Insufficient stock',
      'deduction_success': 'Deduction recorded successfully',
      'stock_updated': 'Stock updated successfully',
      'party_recorded': 'Party expense recorded successfully',
      'no_items_to_save': 'No valid items to save',
      'language': 'Language',
      'english': 'English',
      'hindi': 'Hindi (हिन्दी)',
      'ai_settings': 'AI Integration',
      'ai_api_key': 'OpenAI API Key',
      'ai_enabled': 'Enable AI',
      'ai_auto_automate': 'Auto Automate Tasks',
      'ai_auto_automate_desc': 'Automatically suggest deductions, stock fill and more',
      'backup_restore': 'Backup & Restore',
      'create_backup': 'Create Backup',
      'export_database': 'Export database to a file and share',
      'restore_data': 'Restore Data',
      'import_database': 'Import database from a backup file',
      'party_items': 'Party Items',
      'add_party_item': 'Add Item to Party',
      'bar_item': 'Bar Item',
      'bar_item_name': 'Item Name (Bar Item)',
      'unit': 'Unit (e.g., bottle, peg, glass)',
      'rate_per_unit': 'Rate per unit (₹)',
      'add': 'Add',
      'cancel': 'Cancel',
      'no_party_items': 'No party items yet',
      'items': 'Items',
    },
    'hi': {
      'app_title': 'आर्मी मेस इन्वेंटरी',
      'welcome': 'स्वागत है, क्वार्टरमास्टर',
      'status_operational': 'मेस इन्वेंटरी स्थिति: चालू',
      'total_items': 'कुल आइटम',
      'low_stock': 'कम स्टॉक',
      'daily_deduction': 'रोज़ाना कटौती',
      'monthly_cost': 'मासिक खर्च',
      'quick_actions': 'त्वरित कार्य',
      'stock_management': 'स्टॉक प्रबंधन',
      'manage_inventory': 'इन्वेंटरी आइटम प्रबंधित करें',
      'record_daily_usage': 'रोज़ाना उपयोग दर्ज करें',
      'officer_party': 'अफ़सरों की पार्टी',
      'manage_officer_bills': 'अफ़सरों के बिल प्रबंधित करें',
      'ocr_bill_scan': 'OCR बिल स्कैन',
      'import_bills': 'बिल स्वचालित रूप से इम्पोर्ट करें',
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
      'officers_party_sub': 'अफ़सरों की पार्टी के लिए',
      'daily_deduction_cat': 'रोज़ाना कटौती',
      'daily_deduction_sub': 'रोज़ाना कटौती के लिए',
      'monthly_stock': 'मासिक स्टॉक भरना',
      'monthly_stock_sub': 'मासिक स्टॉक भरने के लिए',
      'stock_fill_details': 'स्टॉक भरने का विवरण',
      'supplier_name': 'आपूर्तिकर्ता का नाम',
      'deduction_details': 'कटौती का विवरण',
      'reason': 'कारण',
      'select_officer': 'अफ़सर चुनें',
      'no_officers': 'कोई अफ़सर पंजीकृत नहीं',
      'add_officer': 'अफ़सर जोड़ें',
      'register_officer': 'अफ़सर पंजीकरण',
      'rank': 'रैंक',
      'name': 'नाम',
      'personal_number': 'व्यक्तिगत नंबर',
      'record_consumption': 'उपभोग दर्ज करें',
      'select_item': 'आइटम चुनें',
      'quantity': 'मात्रा',
      'reason_event': 'कारण/घटना',
      'confirm_deduction': 'कटौती की पुष्टि करें',
      'insufficient_stock': 'अपर्याप्त स्टॉक',
      'deduction_success': 'कटौती सफलतापूर्वक दर्ज',
      'stock_updated': 'स्टॉक सफलतापूर्वक अपडेट',
      'party_recorded': 'पार्टी खर्च सफलतापूर्वक दर्ज',
      'no_items_to_save': 'कोई मान्य आइटम नहीं',
      'language': 'भाषा',
      'english': 'English',
      'hindi': 'हिन्दी',
      'ai_settings': 'AI एकीकरण',
      'ai_api_key': 'OpenAI API Key',
      'ai_enabled': 'AI सक्षम करें',
      'ai_auto_automate': 'स्वचालित कार्य',
      'ai_auto_automate_desc': 'कटौती, स्टॉक भरना और बहुत कुछ स्वचालित सुझाव',
      'backup_restore': 'बैकअप और रिस्टोर',
      'create_backup': 'बैकअप बनाएं',
      'export_database': 'डेटाबेस को फ़ाइल में एक्सपोर्ट करें',
      'restore_data': 'डेटा रिस्टोर करें',
      'import_database': 'बैकअप फ़ाइल से डेटाबेस इम्पोर्ट करें',
      'party_items': 'पार्टी आइटम',
      'add_party_item': 'पार्टी में आइटम जोड़ें',
      'bar_item': 'बार आइटम',
      'bar_item_name': 'आइटम का नाम (बार आइटम)',
      'unit': 'इकाई (जैसे बॉटल, पेग, ग्लास)',
      'rate_per_unit': 'प्रति इकाई दर (₹)',
      'add': 'जोड़ें',
      'cancel': 'रद्द करें',
      'no_party_items': 'कोई पार्टी आइटम नहीं',
      'items': 'आइटम',
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
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
