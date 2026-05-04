# n8n Monitor

A Flutter app for **Android and macOS** that gives you a clean, read-only dashboard for your self-hosted [n8n](https://n8n.io) instance.

No editing, no node building — just the controls you actually need day-to-day:
- View all your workflows and their active/inactive status
- See the last execution result at a glance
- Activate or deactivate workflows with a toggle
- Manually trigger workflows that don't run on a schedule
- Delete workflows or individual execution records
- Metrics header: total workflows, active count, last success/error counts

---

## Requirements

| Tool | Version |
|---|---|
| Flutter | ≥ 3.19 |
| Dart | ≥ 3.3 |
| n8n | Any version with REST API v1 enabled |

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/rubenalejandrocalderoncorona/n8n-monitor.git
cd n8n-monitor
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run on macOS

```bash
flutter run -d macos
```

### 4. Run on Android

Make sure the Android SDK is installed (via [Android Studio](https://developer.android.com/studio)).

```bash
flutter devices            # list available devices/emulators
flutter run -d <device-id>
```

### 5. Build release

```bash
# macOS
flutter build macos

# Android APK
flutter build apk --release
```

---

## Connecting to n8n

On first launch the app shows the **Settings** screen.

1. Enter your n8n **Base URL** — e.g. `https://n8n.example.com`
2. Enter your **API Key** — generate one in n8n under *Settings → API → Create API Key*
3. Tap **Save & Connect**

Credentials are stored in the platform's secure keychain (macOS Keychain / Android Keystore) via `flutter_secure_storage`.

---

## Project Structure

```
lib/
├── main.dart                   # App entry, theme, home routing
├── app_theme.dart              # Dark theme constants
├── models/                     # Workflow, Execution, AppSettings data classes
├── services/                   # n8n REST API client (Dio) + secure settings storage
├── providers/                  # Riverpod state: settings, workflows, executions
├── screens/                    # Settings, Workflows list, Workflow detail
└── widgets/                    # Reusable UI: cards, badges, chips, metrics header
```

---

## Tech Stack

| Concern | Library |
|---|---|
| State management | [flutter_riverpod](https://riverpod.dev) |
| HTTP client | [dio](https://pub.dev/packages/dio) |
| Secure storage | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Timestamps | [timeago](https://pub.dev/packages/timeago) |

---

## n8n API

The app targets the [n8n REST API v1](https://docs.n8n.io/api/). Enable it in your n8n instance under *Settings → API*.

---

## License

MIT
