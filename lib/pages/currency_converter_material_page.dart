import 'package:flutter/material.dart';

/// Equivalent to an Android Activity/Fragment that contains both:
/// 1. Layout (what you wrote in XML)
/// 2. Logic (what you wrote in Java/Kotlin MainActivity)
class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  // ---------------------------------------------------------------------------
  // 1. STATE & CONTROLLERS
  // In Android XML: You would get these via findViewById(R.id.etAmount)
  // In Flutter: We use a TextEditingController to observe and control input.
  // ---------------------------------------------------------------------------
  final TextEditingController _amountController = TextEditingController();

  // Selected Currencies (like Spinner selection in Android)
  String _fromCurrency = 'USD';
  String _toCurrency = 'PKR';
  double _convertedResult = 0.0;
  String? _errorMessage;

  // Base rates relative to 1 USD
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,       // US Dollar
    'PKR': 278.50,    // Pakistani Rupee
    'INR': 83.45,     // Indian Rupee
    'EUR': 0.92,      // Euro
    'GBP': 0.79,      // British Pound
    'AED': 3.67,      // UAE Dirham
    'SAR': 3.75,      // Saudi Riyal
    'CAD': 1.37,      // Canadian Dollar
  };

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'PKR': 'Rs',
    'INR': '₹',
    'EUR': '€',
    'GBP': '£',
    'AED': 'AED',
    'SAR': 'SAR',
    'CAD': 'CA\$',
  };

  // ---------------------------------------------------------------------------
  // 2. BUSINESS LOGIC (Conversion Formula)
  // In Android Java: You would run this inside btnConvert.setOnClickListener {...}
  // In Flutter: We update state inside setState() to automatically trigger UI rebuild!
  // ---------------------------------------------------------------------------
  void _convertCurrency() {
    final text = _amountController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an amount';
        _convertedResult = 0.0;
      });
      return;
    }

    final enteredAmount = double.tryParse(text);

    if (enteredAmount == null || enteredAmount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid positive number';
        _convertedResult = 0.0;
      });
      return;
    }

    final fromRate = _exchangeRates[_fromCurrency] ?? 1.0;
    final toRate = _exchangeRates[_toCurrency] ?? 1.0;

    // Convert: (Amount / FromCurrencyRate) * ToCurrencyRate
    final result = (enteredAmount / fromRate) * toRate;

    setState(() {
      _errorMessage = null;
      _convertedResult = result;
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    if (_amountController.text.isNotEmpty) {
      _convertCurrency();
    }
  }

  void _quickAdd(double value) {
    final current = double.tryParse(_amountController.text) ?? 0.0;
    final updated = current + value;
    _amountController.text = updated.toStringAsFixed(0);
    _convertCurrency();
  }

  void _clearAll() {
    setState(() {
      _amountController.clear();
      _convertedResult = 0.0;
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 3. UI LAYOUT
  // In Android: This replaces activity_main.xml (<LinearLayout>, <CardView>, etc.)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toSymbol = _currencySymbols[_toCurrency] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Clear input',
            icon: const Icon(Icons.refresh),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // A. RESULT CARD (Equivalent to CardView with TextViews in XML)
              // ---------------------------------------------------------------
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E88E5).withOpacity(0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'CONVERTED RESULT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$toSymbol ${_convertedResult.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 $_fromCurrency = ${((_exchangeRates[_toCurrency] ?? 1.0) / (_exchangeRates[_fromCurrency] ?? 1.0)).toStringAsFixed(4)} $_toCurrency',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---------------------------------------------------------------
              // B. CURRENCY SELECTION ROW (Dropdowns & Swap Button)
              // In XML: Two <Spinner> elements and one <ImageButton>
              // ---------------------------------------------------------------
              Row(
                children: [
                  // FROM CURRENCY
                  Expanded(
                    child: _buildCurrencyDropdown(
                      label: 'From',
                      value: _fromCurrency,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _fromCurrency = val);
                          _convertCurrency();
                        }
                      },
                    ),
                  ),

                  // SWAP BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Color(0xFF1E88E5)),
                        tooltip: 'Swap Currencies',
                        onPressed: _swapCurrencies,
                      ),
                    ),
                  ),

                  // TO CURRENCY
                  Expanded(
                    child: _buildCurrencyDropdown(
                      label: 'To',
                      value: _toCurrency,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _toCurrency = val);
                          _convertCurrency();
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------------
              // C. AMOUNT INPUT FIELD (Equivalent to <EditText> in XML)
              // ---------------------------------------------------------------
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _convertCurrency(),
                decoration: InputDecoration(
                  labelText: 'Amount in $_fromCurrency',
                  hintText: 'Enter amount (e.g. 100)',
                  errorText: _errorMessage,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Center(
                      widthFactor: 0.0,
                      child: Text(
                        _currencySymbols[_fromCurrency] ?? '\$',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: _amountController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: _clearAll,
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // D. QUICK ADD BUTTONS (Convenience Chips)
              // ---------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickButton('+10', 10),
                  _buildQuickButton('+50', 50),
                  _buildQuickButton('+100', 100),
                  _buildQuickButton('+500', 500),
                ],
              ),

              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // E. CONVERT BUTTON (Equivalent to <Button> in XML)
              // ---------------------------------------------------------------
              ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'CONVERT NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1E88E5)),
              items: _exchangeRates.keys.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(
                    currency,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, double value) {
    return OutlinedButton(
      onPressed: () => _quickAdd(value),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1E88E5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
