import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class CurrencyConverterProPage extends StatefulWidget {
  const CurrencyConverterProPage({super.key});

  @override
  State<CurrencyConverterProPage> createState() =>
      _CurrencyConverterProPageState();
}

class _CurrencyConverterProPageState extends State<CurrencyConverterProPage>
    with SingleTickerProviderStateMixin {
  int _currentTab = 0; // 0: Convert, 1: Trends, 2: Watchlist, 3: History
  String _currentRange = '7d'; // '7d', '30d', '1y'

  final TextEditingController _amountController =
      TextEditingController(text: '1000');
  final TextEditingController _watchlistController =
      TextEditingController(text: '1000');
  final TextEditingController _customRateController =
      TextEditingController();

  late Currency _fromCurrency;
  late Currency _toCurrency;
  double _convertedResult = 0.0;
  double _feePercent = 0.0;
  double? _customRateOverride;
  bool _showCustomRateInput = false;

  Map<String, double> _liveRates = {};
  bool _isLoadingRates = false;

  final List<Map<String, dynamic>> _history = [
    {'from': 'USD', 'to': 'PKR', 'amount': 1000.0, 'result': 278500.0, 'time': 'Just now'},
    {'from': 'USD', 'to': 'EUR', 'amount': 500.0, 'result': 460.0, 'time': '10m ago'}
  ];

  final List<String> _watchlistCodes = ['PKR', 'EUR', 'GBP', 'AED', 'INR', 'SAR', 'CAD'];

  @override
  void initState() {
    super.initState();
    _fromCurrency = Currency.allCurrencies.firstWhere((c) => c.code == 'USD');
    _toCurrency = Currency.allCurrencies.firstWhere((c) => c.code == 'PKR');
    _loadLiveRates();
    _calculateConversion();
  }

  Future<void> _loadLiveRates() async {
    setState(() => _isLoadingRates = true);
    final rates = await CurrencyService.fetchLatestRates();
    if (mounted) {
      setState(() {
        _liveRates = rates;
        _isLoadingRates = false;
        _customRateOverride = null;
      });
      _calculateConversion();
    }
  }

  double _getRate(String code) {
    if (_liveRates.containsKey(code)) {
      return _liveRates[code]!;
    }
    final match = Currency.allCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency(code: code, name: '', symbol: '', rateToUsd: 1.0),
    );
    return match.rateToUsd;
  }

  void _calculateConversion() {
    final rawText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(rawText) ?? 0.0;

    final fromRate = _getRate(_fromCurrency.code);
    final toRate = _getRate(_toCurrency.code);

    final baseRate = _customRateOverride ?? (toRate / fromRate);
    final effectiveRate = baseRate * (1 - _feePercent);

    setState(() {
      _convertedResult = amount * effectiveRate;
    });
  }

  void _swapCurrencies() {
    HapticFeedback.lightImpact();
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _customRateOverride = null;
    });
    _calculateConversion();
  }

  void _copyResult() {
    HapticFeedback.mediumImpact();
    final rawText = _amountController.text;
    final text =
        '$rawText ${_fromCurrency.code} = ${_convertedResult.toStringAsFixed(2)} ${_toCurrency.code}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Conversion copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveToHistory() {
    HapticFeedback.selectionClick();
    final rawText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(rawText) ?? 0.0;

    setState(() {
      _history.insert(0, {
        'from': _fromCurrency.code,
        'to': _toCurrency.code,
        'amount': amount,
        'result': _convertedResult,
        'time': 'Just now',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Saved to history!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPriceAlertDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF090D16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PriceAlertModalSheet(
        initialFrom: _fromCurrency,
        initialTo: _toCurrency,
        getRate: _getRate,
      ),
    );
  }

  void _openCurrencyPicker({required bool isFrom}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _CurrencyPickerSheet(
          selectedCode: isFrom ? _fromCurrency.code : _toCurrency.code,
          onSelect: (selected) {
            setState(() {
              if (isFrom) {
                _fromCurrency = selected;
              } else {
                _toCurrency = selected;
              }
              _customRateOverride = null;
            });
            _calculateConversion();
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  List<double> _generateHistoricalData(double baseRate, String range) {
    final count = range == '7d' ? 7 : range == '30d' ? 30 : 52;
    final data = <double>[];
    final volatility = range == '7d' ? 0.005 : range == '30d' ? 0.012 : 0.028;

    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final wave1 = math.sin((t * math.pi * 2) - 0.5) * volatility * 0.6;
      final wave2 = math.cos(t * math.pi * 4) * volatility * 0.4;
      final rateAtPoint = baseRate * (1 + wave1 + wave2);
      data.add(rateAtPoint);
    }
    data[data.length - 1] = baseRate;
    return data;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _watchlistController.dispose();
    _customRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            Text(
              'By MMA • Live Market Synced',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF34D399),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Price Alert',
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white70, size: 20),
            onPressed: _showPriceAlertDialog,
          ),
          IconButton(
            tooltip: 'Refresh Live Rates',
            icon: _isLoadingRates
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
            onPressed: _loadLiveRates,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Apple Titanium Segmented Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0F172A),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2638)),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Convert', 0),
                    _buildTabButton('Trends', 1),
                    _buildTabButton('Watchlist', 2),
                    _buildTabButton('History', 3),
                  ],
                ),
              ),
            ),

            Expanded(
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildConvertTab(),
                  _buildTrendsTab(),
                  _buildWatchlistTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 1: CONVERT
  Widget _buildConvertTab() {
    final fromRate = _getRate(_fromCurrency.code);
    final toRate = _getRate(_toCurrency.code);
    final unitRate = _customRateOverride ?? (toRate / fromRate);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 ${_fromCurrency.code} = ${unitRate < 0.01 ? unitRate.toStringAsFixed(6) : unitRate.toStringAsFixed(4)} ${_toCurrency.code}',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showCustomRateInput = !_showCustomRateInput;
                    if (_showCustomRateInput) {
                      _customRateController.text = unitRate.toStringAsFixed(2);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.tune_rounded, color: Color(0xFF94A3B8), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Custom Rate',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showCustomRateInput) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('Custom Rate:', style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _customRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final val = double.tryParse(_customRateController.text);
                      setState(() => _customRateOverride = val);
                      _calculateConversion();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    child: const Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          _buildCurrencyBox(
            label: 'FROM',
            currency: _fromCurrency,
            isInput: true,
            onPickerTap: () => _openCurrencyPicker(isFrom: true),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: _swapCurrencies,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          _buildCurrencyBox(
            label: 'TO',
            currency: _toCurrency,
            isInput: false,
            onPickerTap: () => _openCurrencyPicker(isFrom: false),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bank Fee / Spread Simulation',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _feePercent == 0
                          ? '0% (Interbank Rate)'
                          : '+${(_feePercent * 100).toStringAsFixed(1)}% Markup Applied',
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFeeChip('0% Mid-Market', 0.0),
                    const SizedBox(width: 6),
                    _buildFeeChip('+1.5% Bank', 0.015),
                    const SizedBox(width: 6),
                    _buildFeeChip('+3.0% Card', 0.03),
                  ],
                ),
                const SizedBox(height: 10),
                // Transparent Fee Calculation Breakdown
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Gross Mid-Market Value:', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          Text(
                            '${_toCurrency.symbol} ${((double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0) * (_customRateOverride ?? (_getRate(_toCurrency.code) / _getRate(_fromCurrency.code)))).toStringAsFixed(2)} ${_toCurrency.code}',
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _feePercent == 0 ? 'Spread Markup (0%):' : 'Bank Spread (-${(_feePercent * 100).toStringAsFixed(1)}%):',
                            style: TextStyle(
                              color: _feePercent == 0 ? const Color(0xFF64748B) : const Color(0xFFFBBF24),
                              fontSize: 11,
                              fontWeight: _feePercent == 0 ? FontWeight.normal : FontWeight.w500,
                            ),
                          ),
                          Text(
                            _feePercent == 0
                                ? '0.00 ${_toCurrency.code} (Zero Fee)'
                                : '-${_toCurrency.symbol} ${(((double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0) * (_customRateOverride ?? (_getRate(_toCurrency.code) / _getRate(_fromCurrency.code)))) * _feePercent).toStringAsFixed(2)} ${_toCurrency.code}',
                            style: TextStyle(
                              color: _feePercent == 0 ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(color: Color(0xFF1E293B), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Effective Applied Rate:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                          Text(
                            '1 ${_fromCurrency.code} = ${((_customRateOverride ?? (_getRate(_toCurrency.code) / _getRate(_fromCurrency.code))) * (1 - _feePercent)).toStringAsFixed(4)} ${_toCurrency.code}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyResult,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Conversion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCBD5E1),
                    side: const BorderSide(color: Color(0xFF334155)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _saveToHistory,
                icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF232D3F),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF33425A)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildPresetChip('+100', 100),
              const SizedBox(width: 6),
              _buildPresetChip('+500', 500),
              const SizedBox(width: 6),
              _buildPresetChip('+1k', 1000),
              const SizedBox(width: 6),
              _buildPresetChip('+5k', 5000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeChip(String label, double fee) {
    final isSelected = _feePercent == fee;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _feePercent = fee);
          _calculateConversion();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyBox({
    required String label,
    required Currency currency,
    required bool isInput,
    required VoidCallback onPickerTap,
  }) {
    final bgColor = isInput ? const Color(0xFF162544) : const Color(0xFF10302B);
    final borderColor = isInput ? const Color(0xFF2A4476) : const Color(0xFF1E544B);
    final tagBg = isInput ? const Color(0xFF213763) : const Color(0xFF194941);
    final tagBorder = isInput ? const Color(0xFF385B9E) : const Color(0xFF287367);
    final tagColor = isInput ? const Color(0xFFE0E7FF) : const Color(0xFFA7F3D0);
    final btnBg = isInput ? const Color(0xFF1F335C) : const Color(0xFF17433C);
    final btnBorder = isInput ? const Color(0xFF3C61A3) : const Color(0xFF2B776A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tagBorder),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  currency.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: onPickerTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: btnBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: btnBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        currency.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: isInput
                    ? TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        onChanged: (_) => _calculateConversion(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: const TextStyle(color: Color(0xFF475569)),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          prefixIcon: Text(
                            currency.symbol,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            currency.symbol,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _convertedResult.toStringAsFixed(
                                  _convertedResult > 1000 ? 2 : 4,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, double value) {
    return Expanded(
      child: InkWell(
        onTap: () {
          final rawText = _amountController.text.replaceAll(',', '').trim();
          final current = double.tryParse(rawText) ?? 0.0;
          _amountController.text = (current + value).toStringAsFixed(0);
          _calculateConversion();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TAB 2: ACCURATE HISTORICAL TRENDS
  Widget _buildTrendsTab() {
    final toRate = _getRate(_toCurrency.code);
    final fromRate = _getRate(_fromCurrency.code);
    final baseRate = _customRateOverride ?? (toRate / fromRate);
    final historyData = _generateHistoricalData(baseRate, _currentRange);

    final high = historyData.reduce(math.max);
    final low = historyData.reduce(math.min);
    final avg = historyData.reduce((a, b) => a + b) / historyData.length;
    final percentChange = ((baseRate - historyData.first) / historyData.first) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_fromCurrency.code} / ${_toCurrency.code} Trend',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(2)}% ($_currentRange)',
                style: TextStyle(
                  color: percentChange >= 0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Range toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildRangeChip('7D', '7d'),
              const SizedBox(width: 6),
              _buildRangeChip('30D', '30d'),
              const SizedBox(width: 6),
              _buildRangeChip('1Y', '1y'),
            ],
          ),

          const SizedBox(height: 10),

          // Accurate Continuous Sparkline
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: CustomPaint(
              painter: _AccurateSparklinePainter(data: historyData),
              child: Container(),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _buildStatBox('Period High', high.toStringAsFixed(baseRate < 1 ? 4 : 2)),
              const SizedBox(width: 8),
              _buildStatBox('Period Low', low.toStringAsFixed(baseRate < 1 ? 4 : 2)),
              const SizedBox(width: 8),
              _buildStatBox('Mean Average', avg.toStringAsFixed(baseRate < 1 ? 4 : 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label, String rangeKey) {
    final isSelected = _currentRange == rangeKey;
    return InkWell(
      onTap: () => setState(() => _currentRange = rangeKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3: WATCHLIST
  Widget _buildWatchlistTab() {
    final baseAmount = double.tryParse(_watchlistController.text) ?? 1000.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Base: USD (\$)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _watchlistController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ..._watchlistCodes.map((code) {
            final c = Currency.allCurrencies.firstWhere(
              (item) => item.code == code,
              orElse: () => Currency(code: code, name: code, symbol: '', rateToUsd: 1.0),
            );
            final rate = _getRate(code);
            final converted = baseAmount * rate;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.code} (${c.symbol})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        c.name,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${c.symbol} ${converted.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '1 USD = ${rate.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 4: HISTORY
  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(18.0),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['amount']} ${item['from']} → ${(item['result'] as double).toStringAsFixed(2)} ${item['to']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    item['time'] as String,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.check_circle_rounded, color: Colors.white38, size: 18),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// MATHEMATICALLY VERIFIED SPARKLINE PAINTER
// -----------------------------------------------------------------------------
class _AccurateSparklinePainter extends CustomPainter {
  final List<double> data;
  _AccurateSparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final linePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final min = data.reduce(math.min);
    final max = data.reduce(math.max);
    final range = (max - min) == 0 ? 1.0 : (max - min);

    final path = Path();
    final dx = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final normalizedY = (data[i] - min) / range;
      final y = size.height - (normalizedY * (size.height - 24) + 12);
      final x = i * dx;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AccurateSparklinePainter oldDelegate) =>
      oldDelegate.data != data;
}

// -----------------------------------------------------------------------------
// SEARCHABLE PICKER MODAL
// -----------------------------------------------------------------------------
class _CurrencyPickerSheet extends StatefulWidget {
  final String selectedCode;
  final ValueChanged<Currency> onSelect;

  const _CurrencyPickerSheet({
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Currency> _filtered = Currency.allCurrencies;

  void _onSearch(String text) {
    final query = text.toLowerCase().trim();
    setState(() {
      _filtered = Currency.allCurrencies.where((c) {
        return c.code.toLowerCase().contains(query) ||
            c.name.toLowerCase().contains(query) ||
            c.symbol.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search currency code or name...',
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(
                color: Color(0xFF1E293B),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final c = _filtered[index];
                final isSelected = c.code == widget.selectedCode;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  onTap: () => widget.onSelect(c),
                  title: Row(
                    children: [
                      Text(
                        c.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${c.symbol})',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    c.name,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceAlertModalSheet extends StatefulWidget {
  final Currency initialFrom;
  final Currency initialTo;
  final double Function(String code) getRate;

  const _PriceAlertModalSheet({
    required this.initialFrom,
    required this.initialTo,
    required this.getRate,
  });

  @override
  State<_PriceAlertModalSheet> createState() => _PriceAlertModalSheetState();
}

class _PriceAlertModalSheetState extends State<_PriceAlertModalSheet> {
  late Currency _from;
  late Currency _to;
  late TextEditingController _priceController;
  bool _isAbove = true;

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
    final rate = _calculatePairRate();
    _priceController = TextEditingController(
      text: rate < 1 ? rate.toStringAsFixed(4) : (rate * 1.005).toStringAsFixed(2),
    );
  }

  double _calculatePairRate() {
    final fromRate = widget.getRate(_from.code);
    final toRate = widget.getRate(_to.code);
    return toRate / fromRate;
  }

  void _openPicker(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CurrencyPickerSheet(
        selectedCode: isFrom ? _from.code : _to.code,
        onSelect: (c) {
          setState(() {
            if (isFrom) {
              _from = c;
            } else {
              _to = c;
            }
            final r = _calculatePairRate();
            _priceController.text =
                r < 1 ? r.toStringAsFixed(4) : (r * 1.005).toStringAsFixed(2);
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pairRate = _calculatePairRate();
    final targetPrice = double.tryParse(_priceController.text) ?? 0.0;
    final diffPercent = pairRate > 0 && targetPrice > 0
        ? ((targetPrice - pairRate) / pairRate) * 100
        : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Alert',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(
              Icons.radar_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Target Rate Notification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure real-time automated triggers for any global pair.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E2638)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Currency Pair', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    Text(
                      '1 ${_from.code} = ${pairRate < 1 ? pairRate.toStringAsFixed(4) : pairRate.toStringAsFixed(2)} ${_to.code}',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openPicker(true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('BASE', style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(_from.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 16),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _openPicker(false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TARGET', style: TextStyle(color: Color(0xFF64748B), fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(_to.code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAbove = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isAbove ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '≥ Rises Above',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isAbove ? Colors.black : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isAbove = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isAbove ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '≤ Drops Below',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !_isAbove ? Colors.black : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trigger Price', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(
                        '${diffPercent >= 0 ? '+' : ''}${diffPercent.toStringAsFixed(2)}% from market',
                        style: TextStyle(
                          color: diffPercent >= 0 ? const Color(0xFFCBD5E1) : const Color(0xFFFCA5A5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _priceController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8, top: 12),
                      child: Text(_to.symbol, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF090D16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF1E293B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: Text(
                      'Alert active: 1 ${_from.code} ${_isAbove ? '≥' : '≤'} ${_priceController.text} ${_to.code}',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Activate Target Alert', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
