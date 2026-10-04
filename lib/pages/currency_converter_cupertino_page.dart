import 'package:flutter/cupertino.dart';

/// iOS-styled Currency Converter (Cupertino Design)
/// Lectures often introduce this right after Material to show Flutter's cross-platform power.
class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State<CurrencyConverterCupertinoPage> createState() =>
      _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState
    extends State<CurrencyConverterCupertinoPage> {
  final TextEditingController _amountController = TextEditingController();
  double _result = 0.0;
  final double _usdToPkr = 278.50;

  void _convert() {
    final entered = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _result = entered * _usdToPkr;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Currency Converter (iOS)'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PKR ${_result.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoTextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                placeholder: 'Enter amount in USD',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(
                    CupertinoIcons.money_dollar,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _convert,
                  child: const Text('Convert'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
