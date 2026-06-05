<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=FF6B35&height=200&section=header&text=KitchX&fontSize=80&fontColor=ffffff&fontAlignY=38&desc=Premium%20Kitchen%20Command%20Center&descAlignY=60&descColor=ffffff&descSize=20&animation=fadeIn" width="100%"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![SQL Server](https://img.shields.io/badge/SQL_Server-2019-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![ASP.NET](https://img.shields.io/badge/ASP.NET-Web_API-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)](https://dotnet.microsoft.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=for-the-badge&logo=android&logoColor=white)](https://flutter.dev)

<br/>

> **A stunning real-time kitchen display system that transforms restaurant order management**  
> Built with Flutter · Powered by SQL Server · Designed to move at the speed of a professional kitchen.

<br/>

[**Explore Features**](#-features) · [**Architecture**](#-architecture) · [**API Docs**](#-api-reference) · [**Install**](#-installation) · [**Performance**](#-performance)

<br/>

</div>

---

## ✦ Features

<br/>

### 🎯 Core Functionality

| Feature | Description |
|--------|-------------|
| **Real-time Order Display** | Live pending orders streamed from SQL Server with 30-second auto-refresh |
| **7 Kitchen Stations** | Dedicated views for MK, K1, K5, K11, K4, K22, K23 — each with custom color identity |
| **One-Tap Toggle** | Tap to mark ready · Tap again to revert — no undo buttons, no snackbars |
| **Auto-refresh** | 30-second polling keeps every station in perfect sync |

<br/>

### 🎨 Premium UI/UX

| Feature | Description |
|--------|-------------|
| **Glassmorphism Design** | Frosted glass effects, backdrop blur, warm orange gradient backgrounds |
| **3D Button System** | Custom 3D press animation with haptic feedback on every interaction |
| **Completion Animation** | 3-phase professional sequence — border sweep → green wash → card collapse |
| **Responsive Scaling** | Perfect 0.85× to 1.3× scaling across all device sizes |

<br/>

### 🚀 3D Integration

| Feature | Description |
|--------|-------------|
| **Interactive 3D Chef** | Touch-enabled rotation on splash screen via Google Model Viewer |
| **Background Models** | Auto-rotating grill & chef models on kitchen selection screen |
| **GitHub CDN Hosted** | Fast-loading GLB files served from GitHub raw URLs |

<br/>

### 🗄️ Backend Integration

| Feature | Description |
|--------|-------------|
| **SQL Server Direct** | Full CRUD via optimized stored procedures |
| **REST API** | Swagger-documented endpoints, fully typed responses |
| **Mock Data System** | One boolean flag toggles between mock and live data |

---

## 📊 Performance

<br/>

<div align="center">

| Metric | Value |
|--------|-------|
| 📦 App Size | ~75 MB |
| ⚡ API Response | 200–300 ms |
| 🎬 Animation FPS | 60 FPS |
| 💾 Memory Usage | ~150 MB |
| 🔄 Auto-refresh | 30 seconds |
| 📐 Screen Scaling | 0.85× – 1.3× |

</div>

---

## 🏗 Architecture

<br/>

```
┌─────────────────────────────────────────────────────────────────┐
│                      KitchX  Architecture                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│   ┌─────────────┐    HTTP/JSON    ┌─────────────┐               │
│   │  Flutter App │ ◀────────────▶ │  REST API   │               │
│   │  Dart 3.0+  │                 │  ASP.NET    │               │
│   └─────────────┘                 └──────┬──────┘               │
│          │                               │                       │
│          ▼                               ▼                       │
│   ┌─────────────┐               ┌─────────────────┐             │
│   │  Mock Data  │               │   SQL Server    │             │
│   │  Dev Mode   │               │  Stored Procs   │             │
│   └─────────────┘               └─────────────────┘             │
│                                                                   │
│   ┌──────────┬────────────┬──────────────┬────────────────┐     │
│   │  Splash  │  Kitchen   │    Order     │   3D Models    │     │
│   │  Screen  │  Selection │   Display   │   (WebView)    │     │
│   ├──────────┼────────────┼──────────────┼────────────────┤     │
│   │ Button3D │  Animator  │  API Service │   Responsive   │     │
│   └──────────┴────────────┴──────────────┴────────────────┘     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

<br/>

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # MaterialApp configuration
│
├── config/
│   ├── api_config.dart                 # API endpoints & mock flag
│   ├── app_colors.dart                 # Centralized color system
│   └── responsive.dart                 # Screen-size scaling
│
├── models/
│   ├── kitchen.dart                    # Kitchen data model
│   ├── order_item.dart                 # Order item model
│   └── pending_order.dart              # Order with API parsing
│
├── services/
│   ├── api_service.dart                # HTTP API calls
│   └── cache_service.dart              # 3D model caching
│
├── screens/
│   ├── premium_splash_screen.dart      # Animated splash + 3D chef
│   ├── kitchen_selection_screen.dart   # 7-kitchen grid
│   └── kitchen_orders_screen.dart      # Live order display
│
├── widgets/
│   ├── chef_3d_viewer.dart             # 3D chef model widget
│   ├── button_3d.dart                  # Premium 3D button
│   └── order_completion_animator.dart  # Completion animation
│
└── data/
    └── mock_orders.dart                # Development mock data
```

---

## 🛠 Tech Stack

<br/>

<div align="center">

| Category | Technology |
|----------|------------|
| **Frontend** | Flutter 3.0+ / Dart 3.0+ |
| **Backend** | ASP.NET Web API / IIS |
| **Database** | Microsoft SQL Server 2019 |
| **3D Rendering** | Google Model Viewer (WebView) |
| **API Testing** | Postman / Swagger |
| **State Management** | StatefulWidget + AnimationController |
| **HTTP Client** | `http` package |

</div>

---

## 📡 API Reference

<br/>

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/KitchenMst` | Fetch all kitchen stations |
| `POST` | `/GetPendingItemReady` | Load pending orders for a kitchen |
| `POST` | `/SetItemReady` | Toggle item ready / pending status |
| `GET` | `/GetOutletMst` | Retrieve outlet master data |
| `POST` | `/GetWaiterMst` | Get waiter master list |

<br/>

### SetItemReady — Request Payload

```json
{
    "OutletCode":   "BAR",
    "KotNo":        701,
    "ItemCode":     "42002",
    "SerialNo":     "1",
    "ItemReadyFlg": "I",
    "ItemReadyBy":  "CHEF001",
    "KitchenCode":  "MK",
    "BrnCode":      "001",
    "CompCode":     "001"
}
```

---

## ✨ Completion Animation

When the last item in a KOT is ticked, a precise **2.4-second sequence** plays automatically.

<br/>

```
Phase A  ─────────────────────────────  0ms → 1008ms
  Border sweep — a green line traces the card's rounded border
  clockwise using PathMetric. Deliberate and final, like a stamp.

Phase B  ─────────────────────────────  864ms → 1632ms
  Green wash — a translucent gradient descends top to bottom at
  6–10% opacity with a bright leading edge. Reads like a scanner.

Phase C  ─────────────────────────────  1632ms → 2400ms
  Exit & collapse — card fades with easeInQuart, slides up 32px,
  SizeTransition collapses height to zero. Cards below slide up
  smoothly. No jump, no pop.
```

---

## 🏪 Kitchen Stations

<br/>

<div align="center">

| Code | Station | Section |
|------|---------|---------|
| `MK` | Main Kitchen | Primary Station |
| `K1` | Kitchen 1 | Hot Section |
| `K5` | Kitchen 5 | Cold Section |
| `K11` | Kitchen 11 | Desserts |
| `K4` | Kitchen 4 | Grill |
| `K22` | Kitchen 22 | Bakery |
| `K23` | Kitchen 23 | Bar / Beverages |

</div>

---

## 🚀 Installation

<br/>

**Prerequisites**
- Flutter SDK 3.0+
- Android Studio / VS Code
- SQL Server 2019 (for live data)

<br/>

**1 · Clone**
```bash
git clone https://github.com/veerabathirannatrajan/kitchen_app.git
cd kitchen_app
```

**2 · Install dependencies**
```bash
flutter pub get
```

**3 · Configure API**
```dart
// lib/config/api_config.dart

static const bool useMockData = true;   // development
static const bool useMockData = false;  // production
```

**4 · Run**
```bash
flutter run
```

---

## 🎨 Color System

<br/>

```dart
Primary Orange  →  #FF6B35   // Action, buttons, accents
Orange Soft     →  #FF8C5A   // Hover states, gradients
Success Green   →  #27AE60   // Completed items
Ready Green     →  #2ECC71   // Active ready state
Danger Red      →  #E74C3C   // Error states

Background Gradient:
  #FFF5F0  →  #FFF0E6  →  #FFE8D9  →  #FFDBC8
```

---



---

## 🤝 Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch — `git checkout -b feature/your-feature`
3. Commit your changes — `git commit -m 'Add your feature'`
4. Push to the branch — `git push origin feature/your-feature`
5. Open a Pull Request

---



*Developed by*

## Veerabathiran

[![GitHub](https://img.shields.io/badge/GitHub-@veerabathirannatrajan-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/veerabathirannatrajan)

<br/>

*KitchX — Where Kitchen Meets Technology*

</div>

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=FF6B35&height=120&section=footer" width="100%"/>

<br/>
