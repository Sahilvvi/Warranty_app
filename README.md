# Warranty Management - Flutter Mobile App

A professional Flutter mobile application for managing product warranties, stock inventory across 3 levels (Manufacturer → Distributor → Dealer), and consumer records.

## Features

- **Login & Role Management** — Manufacturer / Distributor / Dealer / Admin
- **Warranty Registration** — Form with photo upload, auto status calculation
- **Warranty Status Logic** — Active / Expire Soon / Expired
- **Stock Management (3 levels)** — Manufacturer → Distributor → Dealer tracking
- **Consumer Details** — End customer records management
- **Product Management** — Add/Edit products with warranty stats
- **Dashboard + Reports** — Overview with charts and recent activity

## API Backend

The app connects to: `https://maruthimotorpump.somee.com`

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code

### Setup
```bash
cd warranty_app
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
```

## Project Structure
```
lib/
├── config/         # API configuration
├── models/         # Data models
├── providers/      # State management (Provider)
├── screens/        # UI screens
│   ├── auth/       # Login
│   ├── home/       # Home with navigation
│   ├── dashboard/  # Dashboard overview
│   ├── warranty/   # Warranty CRUD + registration
│   ├── stock/      # 3-level stock management
│   ├── consumer/   # Consumer management
│   └── product/    # Product management
└── services/       # API service layer
```

## Roles
- **Admin** — Full access to all modules
- **Manufacturer** — Stock creation, product management
- **Distributor** — Receive & distribute stock
- **Dealer** — Warranty registration, stock tracking, consumer management
