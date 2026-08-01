# Army Mess Inventory Management System

A production-ready Flutter Android application for managing Army Mess inventory, daily deductions, and officer party billing.

## Key Features
- **Offline First**: Fully functional without internet using SQLite.
- **OCR Bill Scanning**: Automatically extract items from bill images using Google ML Kit.
- **Clean Architecture**: Highly maintainable and testable code structure.
- **Material 3 UI**: Modern, premium design with glassmorphism effects.
- **PDF Reports**: Generate professional inventory and deduction reports.
- **Officer Management**: Track party entries and calculate costs per officer.
- **Backup & Restore**: Easily backup your database and restore when needed.
- **CI/CD**: Automated release builds via GitHub Actions.

## Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Database**: SQLite (sqflite)
- **OCR**: Google ML Kit Text Recognition
- **Design**: Material 3, Google Fonts, Glassmorphism
- **Reports**: PDF & Printing packages

## Project Structure
```text
lib/
├── core/               # Shared utilities, theme, and base classes
├── features/
│   ├── inventory/      # Core inventory, stock, and deduction logic
│   ├── ocr/            # Bill scanning and text extraction
│   ├── reports/        # PDF generation and analytics
│   └── backup/         # Database backup and restore
└── main.dart           # App entry point
```

## Getting Started
1. Clone the repository.
2. Run `flutter pub get`.
3. Run `flutter pub run build_runner build` (if using code generation).
4. Run `flutter run`.

## License
Private Property of Army Mess Management.
