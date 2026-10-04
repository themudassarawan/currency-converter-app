# 💱 Flutter Currency Converter App

> **Hands-on Practice Guide: Transitioning from Android XML to Flutter**

---

## 📁 Project Structure

```
currency_converter_app/
├── lib/
│   ├── main.dart                                # Application Entry Point
│   └── pages/
│       ├── currency_converter_material_page.dart  # Full Material 3 UI (Android/Web/Desktop)
│       └── currency_converter_cupertino_page.dart # Cupertino iOS style UI
├── android_xml_reference/                        # Side-by-side study guide
│   ├── activity_main.xml                        # Traditional Android XML Layout
│   └── MainActivity.java                        # Imperative Android Java Controller
├── pubspec.yaml                                 # Dependencies & metadata
└── README.md
```

---

## 🧠 Key Conceptual Bridges (XML vs Flutter)

| Concept | Android Native (XML + Java/Kotlin) | Flutter (Dart) |
| :--- | :--- | :--- |
| **Layout Definition** | Declarative XML (`<LinearLayout>`, `<EditText>`) | Declarative Widget Tree (`Column()`, `TextField()`) |
| **Logic Location** | Separate `.java` or `.kt` file | Same Dart file or separate controller/bloc |
| **Element Binding** | `findViewById(R.id.elementId)` | Direct instance references & `TextEditingController` |
| **Updating the Screen** | Imperative mutations: `tvResult.setText("...")` | Reactive state: `setState(() => _result = ...)` |
| **Lifecycle** | `Activity.onCreate()`, `onDestroy()` | `State.initState()`, `State.dispose()`, `State.build()` |

---

## 🚀 How to Run the App

### Option 1: Run in Browser Instantly (DartPad)
1. Open [DartPad.dev](https://dartpad.dev).
2. Copy all contents from [`lib/main.dart`](file:///f:/mudassar-portfolio/currency_converter_app/lib/main.dart) and [`lib/pages/currency_converter_material_page.dart`](file:///f:/mudassar-portfolio/currency_converter_app/lib/pages/currency_converter_material_page.dart).
3. Paste into DartPad and hit **Run**.

### Option 2: Run via Flutter CLI
```bash
cd f:/mudassar-portfolio/currency_converter_app
flutter pub get
flutter run
```

---

## 🛠 Features Implemented
- 🔄 **Multi-Currency Conversion**: USD, PKR, INR, EUR, GBP, AED, SAR, CAD.
- 🔁 **Instant Currency Swap**: Swap "From" and "To" with one tap.
- ⚡ **Live Real-time Calculation**: Automatically calculates as you type or tap Quick Add buttons.
- 🛡 **Input Validation**: Prevents invalid characters and empty submissions.
- 🎨 **Material 3 Design**: Card elevations, gradients, and custom input borders.
