class Currency {
  final String code;
  final String name;
  final String symbol;
  final double rateToUsd;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rateToUsd,
  });

  static const List<Currency> allCurrencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', rateToUsd: 1.0),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', rateToUsd: 0.92),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', rateToUsd: 0.79),
    Currency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs', rateToUsd: 278.50),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', rateToUsd: 83.45),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'AED', rateToUsd: 3.6725),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: 'SAR', rateToUsd: 3.75),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'CA\$', rateToUsd: 1.37),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', rateToUsd: 1.52),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', rateToUsd: 154.20),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', rateToUsd: 0.91),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', rateToUsd: 7.24),
    Currency(code: 'QAR', name: 'Qatari Riyal', symbol: 'QAR', rateToUsd: 3.64),
    Currency(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'KWD', rateToUsd: 0.308),
    Currency(code: 'BHD', name: 'Bahraini Dinar', symbol: 'BHD', rateToUsd: 0.376),
    Currency(code: 'OMR', name: 'Omani Rial', symbol: 'OMR', rateToUsd: 0.385),
    Currency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', rateToUsd: 1.36),
    Currency(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', rateToUsd: 1.67),
    Currency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', rateToUsd: 7.82),
    Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩', rateToUsd: 1380.0),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', rateToUsd: 32.50),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', rateToUsd: 5.25),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: 'Mex\$', rateToUsd: 16.90),
    Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R', rateToUsd: 18.60),
    Currency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', rateToUsd: 10.85),
    Currency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', rateToUsd: 10.95),
    Currency(code: 'DKK', name: 'Danish Krone', symbol: 'kr', rateToUsd: 6.95),
    Currency(code: 'THB', name: 'Thai Baht', symbol: '฿', rateToUsd: 36.80),
    Currency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', rateToUsd: 4.75),
    Currency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', rateToUsd: 16250.0),
    Currency(code: 'PHP', name: 'Philippine Peso', symbol: '₱', rateToUsd: 57.50),
    Currency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', rateToUsd: 25400.0),
    Currency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', rateToUsd: 117.20),
    Currency(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs', rateToUsd: 302.0),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', rateToUsd: 47.60),
    Currency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', rateToUsd: 1450.0),
    Currency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', rateToUsd: 4.02),
    Currency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', rateToUsd: 23.40),
    Currency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪', rateToUsd: 3.72),
    Currency(code: 'RUB', name: 'Russian Ruble', symbol: '₽', rateToUsd: 91.50),
  ];
}
