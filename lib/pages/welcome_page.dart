import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'currency_converter_pro_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Stack(
        children: [
          // Ambient Glow Orbs in Background
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4F46E5).withOpacity(0.12),
              ),
            ),
          ),

          // Ambient Floating Currency Symbols
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final val = _animController.value;
              return Stack(
                children: [
                  _buildFloatingSymbol(
                    symbol: '\$',
                    top: 50 + (math.sin(val * 2 * math.pi) * 14),
                    left: 20,
                    size: 32,
                    opacity: 0.15,
                  ),
                  _buildFloatingSymbol(
                    symbol: '€',
                    top: 80 + (math.cos(val * 2 * math.pi) * 18),
                    right: 25,
                    size: 36,
                    opacity: 0.14,
                  ),
                  _buildFloatingSymbol(
                    symbol: '£',
                    top: 250 + (math.sin(val * math.pi) * 16),
                    left: 12,
                    size: 28,
                    opacity: 0.12,
                  ),
                  _buildFloatingSymbol(
                    symbol: '¥',
                    top: 300 + (math.cos(val * math.pi) * 20),
                    right: 15,
                    size: 38,
                    opacity: 0.13,
                  ),
                  _buildFloatingSymbol(
                    symbol: 'Rs',
                    bottom: 120 + (math.sin(val * 2 * math.pi) * 14),
                    left: 25,
                    size: 32,
                    opacity: 0.14,
                  ),
                  _buildFloatingSymbol(
                    symbol: '₹',
                    bottom: 90 + (math.cos(val * 2 * math.pi) * 16),
                    right: 28,
                    size: 30,
                    opacity: 0.15,
                  ),
                  _buildFloatingSymbol(
                    symbol: 'AED',
                    top: 170 + (math.sin(val * 1.5 * math.pi) * 12),
                    right: 90,
                    size: 22,
                    opacity: 0.10,
                  ),
                  _buildFloatingSymbol(
                    symbol: 'CHF',
                    bottom: 210 + (math.cos(val * 1.5 * math.pi) * 14),
                    left: 80,
                    size: 24,
                    opacity: 0.09,
                  ),
                ],
              );
            },
          ),

          // Frosted Glassmorphism Card (Original Typography & Spacing)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 40.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121929).withOpacity(0.72),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Subtitle: A PROJECT BY MMA
                            const Text(
                              'A PROJECT BY MMA',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Main Title: CURRENCY CONVERTER
                            const Text(
                              'CURRENCY CONVERTER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Tagline (Original Font & Size)
                            const Text(
                              'Real-time global currency valuations and precision exchange rates.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 22),

                            Container(
                              padding: const EdgeInsets.only(top: 18),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withOpacity(0.06),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('40+ Global Currencies',
                                      style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12)),
                                  SizedBox(width: 8),
                                  Text('•',
                                      style:
                                          TextStyle(color: Color(0xFF64748B))),
                                  SizedBox(width: 8),
                                  Text('Live Calculation',
                                      style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Enter Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, anim1, anim2) =>
                              const CurrencyConverterProPage(),
                          transitionsBuilder: (context, anim1, anim2, child) {
                            return FadeTransition(opacity: anim1, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 200),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enter Converter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSymbol({
    required String symbol,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Text(
          symbol,
          style: TextStyle(
            color: const Color(0xFF60A5FA).withOpacity(opacity),
            fontSize: size,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
