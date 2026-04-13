# Sudoku App

Ứng dụng Sudoku được xây dựng bằng Flutter với các tính năng quản lý trạng thái, routing và lưu trữ cục bộ.

## Yêu cầu hệ thống

- Flutter SDK: ^3.11.4
- Dart SDK: ^3.11.4
- Android Studio / Xcode (cho phát triển mobile)
- VS Code hoặc Android Studio (khuyến nghị)

## Cài đặt

### 1. Cài đặt Flutter

Nếu chưa cài Flutter, tải và cài đặt từ [flutter.dev](https://flutter.dev/docs/get-started/install)

Kiểm tra cài đặt:
```bash
flutter doctor
```

### 2. Clone dự án

```bash
git clone <repository-url>
cd sudoku_app
```

### 3. Cài đặt dependencies

```bash
flutter pub get
```

### 4. Chạy ứng dụng

#### Chạy trên Android/iOS:
```bash
flutter run
```

#### Chạy trên Web:
```bash
flutter run -d chrome
```

#### Chạy trên Windows:
```bash
flutter run -d windows
```

#### Chạy trên macOS:
```bash
flutter run -d macos
```

#### Chạy trên Linux:
```bash
flutter run -d linux
```

## Cấu trúc dự án

```
lib/
├── core/           # Core functionality, utilities, constants
├── features/       # Feature modules
├── routes/         # App routing configuration
└── main.dart       # Entry point
```

## Dependencies chính

- **provider** (^6.1.2): Quản lý trạng thái
- **go_router** (^14.6.2): Điều hướng và routing
- **shared_preferences** (^2.3.3): Lưu trữ dữ liệu cục bộ
- **intl** (^0.19.0): Quốc tế hóa và định dạng

## Build cho production

### Android (APK):
```bash
flutter build apk --release
```

### Android (App Bundle):
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web --release
```

### Windows:
```bash
flutter build windows --release
```

### macOS:
```bash
flutter build macos --release
```

### Linux:
```bash
flutter build linux --release
```

## Troubleshooting

### Lỗi dependencies
```bash
flutter clean
flutter pub get
```

### Lỗi build
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Kiểm tra thiết bị
```bash
flutter devices
```

## Hỗ trợ

Nếu gặp vấn đề, vui lòng tạo issue trên repository hoặc liên hệ team phát triển.
# Sokudo_App
