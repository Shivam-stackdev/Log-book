import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:army_mess_inventory/core/utils/database_helper.dart';

class AIService {
  static const String _apiBase = 'https://api.openai.com/v1';

  Future<String?> getApiKey() async {
    final dbHelper = DatabaseHelper.instance;
    final settings = await dbHelper.getAllSettings();
    return settings['ai_api_key']?.isEmpty == true ? null : settings['ai_api_key'];
  }

  Future<bool> isAIServiceConfigured() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// AI-powered bill analysis - extract structured data from OCR text
  Future<Map<String, dynamic>?> analyzeBillText(String ocrText) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a bill/invoice parser. Given OCR text from a bill, extract items into a JSON array with fields: name (item name), quantity (number), unit (unit type), rate (price per unit), amount (total for that line). Return ONLY valid JSON array, no markdown, no explanation.'''
            },
            {
              'role': 'user',
              'content': ocrText,
            },
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Try to parse the JSON array
        try {
          final items = jsonDecode(content);
          if (items is List) {
            return {'items': items, 'success': true};
          }
        } catch (e) {
          return {'error': 'Failed to parse AI response', 'raw': content};
        }
      } else {
        return {'error': 'API Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'Network Error: $e'};
    }
  }

  /// AI-powered deduction suggestion based on current stock
  Future<List<Map<String, dynamic>>?> suggestDeductions(
    List<Map<String, dynamic>> stockData,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return null;

    final stockJson = jsonEncode(stockData);

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a mess inventory manager. Based on the current stock data provided, suggest daily deductions for items that are likely to be consumed. Return a JSON array of objects with: item (item name), suggested_qty (suggested deduction quantity), reason (why). Only suggest items that have sufficient stock.'''
            },
            {
              'role': 'user',
              'content': 'Current stock: $stockJson',
            },
          ],
          'temperature': 0.4,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final suggestions = jsonDecode(content);
          if (suggestions is List) {
            return List<Map<String, dynamic>>.from(suggestions);
          }
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// AI-powered purchase suggestions based on consumption patterns
  Future<List<Map<String, dynamic>>?> suggestPurchases(
    List<Map<String, dynamic>> consumptionData,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return null;

    final consumptionJson = jsonEncode(consumptionData);

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a procurement advisor. Based on consumption data, suggest items that need to be purchased soon. Return a JSON array with: item (item name), suggested_qty (quantity to purchase), priority (high/medium/low), reason (why).'''
            },
            {
              'role': 'user',
              'content': 'Consumption data: $consumptionJson',
            },
          ],
          'temperature': 0.4,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final suggestions = jsonDecode(content);
          if (suggestions is List) {
            return List<Map<String, dynamic>>.from(suggestions);
          }
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// AI-powered cost analysis and anomaly detection
  Future<Map<String, dynamic>?> analyzeCosts(
    List<Map<String, dynamic>> costData,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return null;

    final costJson = jsonEncode(costData);

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are a financial analyst for an army mess. Analyze the cost data and provide: total_spent (total amount), most_expensive_item (item with highest cost), anomalies (any unusual spending patterns), recommendations (cost-saving suggestions). Return as JSON.'''
            },
            {
              'role': 'user',
              'content': 'Cost data: $costJson',
            },
          ],
          'temperature': 0.3,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final analysis = jsonDecode(content);
          if (analysis is Map) {
            return Map<String, dynamic>.from(analysis);
          }
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Auto-automate: Generate daily deduction report
  Future<Map<String, dynamic>?> autoGenerateDailyReport(
    String currentStock,
    String recentDeductions,
  ) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$_apiBase/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': '''You are an army mess automation system. Based on the current stock levels and recent deductions, generate a daily report with: items_to_deduct (suggested items for today's deduction), low_stock_alerts (items running low), purchase_needed (items to order), summary (brief text summary). Return as JSON.'''
            },
            {
              'role': 'user',
              'content': 'Current stock: $currentStock\nRecent deductions: $recentDeductions',
            },
          ],
          'temperature': 0.3,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        try {
          final report = jsonDecode(content);
          if (report is Map) {
            return Map<String, dynamic>.from(report);
          }
        } catch (e) {
          return null;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
