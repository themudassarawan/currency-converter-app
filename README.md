# 💱 Currency Converter App — A Project by MMA

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4E73DF)](https://github.com/themudassarawan/currency-converter-app)
[![Release](https://img.shields.io/badge/Release-v1.0.0%20APK-10B981?logo=android&logoColor=white)](https://github.com/themudassarawan/currency-converter-app/releases)
[![License](https://img.shields.io/badge/License-MIT-gray.svg)](LICENSE)

> **A modern, high-precision cross-platform Currency Converter suite bridging Android Native XML architecture with Flutter declarative reactive state management, designed with an Apple iOS / Swiss Fintech Titanium aesthetic.**

---

## 🔗 Quick Links

- **GitHub Repository**: [https://github.com/themudassarawan/currency-converter-app](https://github.com/themudassarawan/currency-converter-app)
- **Direct APK Download**: [https://github.com/themudassarawan/currency-converter-app/releases](https://github.com/themudassarawan/currency-converter-app/releases)
- **Live Privacy Policy**: [https://themudassarawan.github.io/currency-converter-app/privacy_policy.html](https://themudassarawan.github.io/currency-converter-app/privacy_policy.html)

---

## 🌟 Key Features

### 1. Real-Time Conversion & Searchable Currency Picker
- Supports **40+ global currencies** (USD, EUR, GBP, PKR, INR, AED, SAR, CAD, AUD, JPY, CHF, CNY, QAR, KWD, etc.).
- Instant live exchange rates fetched from Open Exchange Rates endpoint with real-time decimal precision.
- Searchable modal bottom sheet with instant filtering by ISO code or currency name.

### 2. Interactive Historical Trend Valuation Curves
- Historical rate trends over **7-Day (7D)**, **30-Day (30D)**, and **1-Year (1Y)** intervals.
- Custom sparkline vector painter with linear gradient fills and live interactive hover crosshair inspection.
- Calculates Period High, Period Low, Mean Average, and percentage change.

### 3. Multi-Currency Portfolio Watchlist
- Convert a base portfolio amount simultaneously across multiple tracked global currencies in real time.
- Dynamic list updating instantly as the base amount changes.

### 4. Real-World Bank Fee & Spread Simulator
- Transparent mathematical fee simulation:
  - **0% Mid-Market**: Interbank wholesale rate.
  - **+1.5% Bank**: Commercial bank retail spread.
  - **+3.0% Card**: Credit/debit card international markup.
- Real-time breakdown card displaying Gross Value, Spread Deducted, and Net Effective Rate.

### 5. Custom Cash Rate Override
- Allows users to set manual cash or open-market exchange rates (`⚙️ Custom Rate`) bypassing live interbank rates.

### 6. Dynamic Target Price Alert Radar
- Configure automated threshold notifications for **any currency pair**.
- Select condition: **`≥ Rises Above`** or **`≤ Drops Below`**.
- Real-time percentage delta badge calculating deviation from current market rate.

### 7. Automated Offline Caching Fallback
- Seamless offline functionality: if internet is disconnected, the app automatically falls back to local cached exchange rate models.

### 8. Luxury Apple Titanium / Obsidian Dark Theme
- Matte obsidian surfaces (`#0B0E14`, `#101622`), frosted glassmorphism (`BackdropFilter`), vibrant sapphire/emerald card accents, and SF Pro tabular typography.

---

## 📁 Project Architecture & File Map

```
currency_converter_app/
├── lib/
│   ├── main.dart                                # Application Entry Point & Dark Theme
│   ├── models/
│   │   └── currency.dart                        # 40+ World Currencies Model & Rates
│   ├── services/
│   │   └── currency_service.dart                # Live API Client & Offline Cache
│   └── pages/
│       ├── welcome_page.dart                    # Glassmorphism Splash & Floating Physics
│       ├── currency_converter_pro_page.dart     # Complete 4-Tab Fintech Suite
│       ├── currency_converter_material_page.dart# Material 3 Educational Reference
│       └── currency_converter_cupertino_page.dart# Cupertino iOS Reference
├── android_xml_reference/                       # Academic XML vs Flutter Bridge
│   ├── activity_main.xml                        # Traditional Android Native XML Layout
│   └── MainActivity.java                        # Imperative Java Controller
├── android/                                     # Android Native Engine & Gradle Config
├── .github/workflows/
│   └── build_apk.yml                            # GitHub Actions CI/CD Cloud Builder
├── index.html                                   # Web Preview / GitHub Pages Embed
├── privacy_policy.html                          # Google Play Store Privacy Policy
├── pubspec.yaml                                 # Dependencies & Package Config
└── README.md                                    # Project Documentation
```

---

## 🧠 Academic Guide: Android Native XML vs Flutter

| Architectural Concept | Android Native (XML + Java/Kotlin) | Flutter (Dart Declarative UI) |
| :--- | :--- | :--- |
| **UI Definition** | Static XML files (`activity_main.xml`) in `/res/layout/` | Declarative Widget Tree (`Widget build(BuildContext context)`) |
| **View Lookup & Binding** | Imperative `findViewById(R.id.btnConvert)` or ViewBinding | Direct instance references & `TextEditingController` |
| **State Mutation** | Manual imperative updates: `tvResult.setText(result)` | Reactive state: `setState(() => _result = calculatedVal)` |
| **Styling & Themes** | `styles.xml`, `colors.xml`, drawable XML selectors | In-code `ThemeData`, `BoxDecoration`, `LinearGradient` |
| **Animation & Blur** | RenderScript / specialized libraries (`BlurView`) | Built-in `BackdropFilter(filter: ImageFilter.blur(...))` |
| **Platform Target** | Android only | Android, iOS, Web, macOS, Windows, Linux from single codebase |

---

## 🚀 How to Run the Project

### Option 1: Run via Flutter CLI
```bash
# 1. Clone the repository
git clone https://github.com/themudassarawan/currency-converter-app.git

# 2. Navigate to project folder
cd currency-converter-app

# 3. Get dependencies
flutter pub get

# 4. Run on connected device or emulator
flutter run
```

### Option 2: Build Release Android APK / App Bundle
```bash
# Build APK
flutter build apk --release

# Build Google Play Bundle (.aab)
flutter build appbundle --release
```

---

## 👨‍💻 Author & Credits

- **Developer**: Mudassar Awan (MMA)
- **Branding**: A PROJECT BY MMA
- **GitHub**: [@themudassarawan](https://github.com/themudassarawan)
