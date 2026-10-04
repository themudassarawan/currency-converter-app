import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency.dart';

class CurrencyService {
  static const String _apiUrl = 'https://open.er-api.com/v6/latest/USD';

  /// Fetches latest real-time rates with instant offline fallback
  static Future<Map<String, double>> fetchLatestRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success' && data['rates'] != null) {
          final Map<String, dynamic> rawRates = data['rates'];
          final Map<String, double> rates = {};
          rawRates.forEach((key, value) {
            rates[key] = (value as num).toDouble();
          });
          return rates;
        }
      }
    } catch (_) {
      // Offline fallback: Use default baseline rates
    }

    // Default Fallback Rates
    final Map<String, double> fallback = {};
    for (var c in Currency.allCurrencies) {
      fallback[c.code] = c.rateToUsd;
    }
    return fallback;
  }
}
