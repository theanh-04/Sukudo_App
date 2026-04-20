# Sudoku App

Ứng dụng Sudoku được xây dựng bằng Flutter với các tính năng quản lý trạng thái, routing và lưu trữ cục bộ.

## Yêu cầu hệ thống

- Flutter SDK: ^3.11.4 hoặc cao hơn
- Dart SDK: ^3.11.4 hoặc cao hơn
- Android Studio / Xcode (cho phát triển mobile)
- VS Code hoặc Android Studio (khuyến nghị)

## Cài đặt Flutter SDK

### Windows:
1. Tải Flutter SDK từ [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Giải nén vào thư mục (ví dụ: `C:\src\flutter`)
3. Thêm Flutter vào PATH:
   - Mở "Edit environment variables"
   - Thêm `C:\src\flutter\bin` vào PATH
4. Chạy `flutter doctor` để kiểm tra

### macOS:
1. Tải Flutter SDK từ [flutter.dev](https://flutter.dev/docs/get-started/install/macos)
2. Giải nén và thêm vào PATH:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
3. Chạy `flutter doctor` để kiểm tra

### Linux:
1. Tải Flutter SDK từ [flutter.dev](https://flutter.dev/docs/get-started/install/linux)
2. Giải nén và thêm vào PATH
3. Chạy `flutter doctor` để kiểm tra

## Cài đặt dự án

### 1. Clone repository

```bash
git clone https://github.com/Kousei2004/Sokudo_App.git
cd Sokudo_App
```

### 2. Kiểm tra Flutter

```bash
flutter doctor
```

Đảm bảo không có lỗi nghiêm trọng. Nếu có, làm theo hướng dẫn để sửa.

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

### Lỗi "flutter is not recognized"
- Đảm bảo Flutter đã được thêm vào PATH
- Khởi động lại terminal/command prompt
- Chạy `flutter doctor` để kiểm tra

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

### Lỗi "Could not find a Flutter SDK"
- Cài đặt Flutter SDK theo hướng dẫn ở trên
- Hoặc trong VS Code: Ctrl+Shift+P → "Flutter: Change SDK"

## Hỗ trợ


