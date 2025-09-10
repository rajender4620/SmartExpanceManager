# 💰 SmartExpense Manager

<div align="center">
  <img src="assets/icon/app_icon.png" alt="SmartExpense Manager" width="120" height="120">
  
  <h3>A comprehensive Flutter expense tracking application</h3>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)](https://flutter.dev/docs/deployment)
</div>

## 📱 About

SmartExpense Manager is a modern, cross-platform expense tracking application built with Flutter. It helps users manage their finances with intelligent insights, beautiful visualizations, and comprehensive reporting capabilities.

### ✨ Key Features

- 🔐 **Multi-Provider Authentication** - Google Sign-In & Email/Password
- 💳 **Expense Management** - Add, edit, delete, and categorize expenses
- 📊 **Visual Analytics** - Interactive charts and spending trends
- 🎯 **Smart Insights** - AI-driven financial advice and warnings
- 📈 **Comprehensive Reports** - PDF and CSV export capabilities
- 🔄 **Cloud Sync** - Firebase Firestore integration
- 🔔 **Push Notifications** - FCM-powered expense reminders
- 🌙 **Dark/Light Theme** - Material Design 3 theming
- 📝 **Notes Feature** - Keep track of financial notes
- 💾 **Local Storage** - SQLite for offline functionality

### 🏗️ Architecture

- **State Management**: BLoC Pattern with flutter_bloc
- **Database**: SQLite (local) + Firebase Firestore (cloud)
- **Authentication**: Firebase Auth
- **UI Framework**: Material Design 3
- **Charts**: FL Chart for data visualization
- **Export**: PDF & CSV generation

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.7+ (stable)
- **Dart SDK**: 3.0+
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Account** for backend services
- **Android SDK** (for Android development)
- **Xcode** (for iOS development - macOS only)

### 📥 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/smartexpensemanager.git
   cd smartexpensemanager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (See [Firebase Setup Guide](docs/FIREBASE_SETUP.md))
   ```bash
   # Add your google-services.json (Android)
   # Add your GoogleService-Info.plist (iOS)
   ```

4. **Update package name** (See [Deployment Guide](docs/DEPLOYMENT.md))
   - Change `com.example.smartexpencemanager` to your domain
   - Update in `android/app/build.gradle.kts`
   - Update iOS bundle identifier

5. **Run the application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

## 📋 Project Structure

```
lib/
├── blocs/              # BLoC state management
│   ├── auth/          # Authentication logic
│   ├── expense/       # Expense management
│   ├── navigation/    # Navigation state
│   └── theme/         # Theme management
├── models/            # Data models
│   ├── expense.dart
│   ├── expense_category.dart
│   ├── insight.dart
│   └── notes.dart
├── screens/           # UI screens
│   ├── auth_wrapper.dart
│   ├── dashboard_screen.dart
│   ├── expenses_screen.dart
│   ├── insights_screen.dart
│   ├── reports_screen.dart
│   └── ...
├── services/          # Business logic & APIs
│   ├── database_service.dart
│   ├── firebase_auth_service.dart
│   ├── fcm_service.dart
│   ├── backup_service.dart
│   └── ...
├── theme/             # App theming
├── utils/             # Helper utilities
├── widgets/           # Reusable components
└── main.dart          # App entry point
```

## 🔧 Configuration

### Environment Setup

1. **Update Flutter SDK** (if using dev version):
   ```yaml
   # pubspec.yaml
   environment:
     sdk: ^3.16.0  # Use stable version
   ```

2. **Configure App Identity**:
   ```kotlin
   // android/app/build.gradle.kts
   applicationId = "com.yourcompany.smartexpensemanager"
   ```

3. **Remove Debug Code**:
   ```bash
   # Remove all print() statements for production
   grep -r "print(" lib/ --exclude-dir=test
   ```

### Firebase Configuration

Complete setup instructions are available in [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Ready | API Level 23+ |
| iOS | ✅ Ready | iOS 12+ |
| Web | ✅ Ready | PWA support |
| Windows | ✅ Ready | Desktop app |
| macOS | ✅ Ready | Desktop app |
| Linux | ✅ Ready | Desktop app |

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 📦 Building for Production

### Android (AAB/APK)
```bash
# Build AAB for Play Store
flutter build appbundle --release

# Build APK
flutter build apk --release
```

### iOS (IPA)
```bash
# Build for App Store
flutter build ios --release

# Build IPA
flutter build ipa --release
```

See [Deployment Guide](docs/DEPLOYMENT.md) for detailed instructions.

## 🚀 Features Deep Dive

### 💰 Expense Management
- **8 Categories**: Food, Travel, Bills, Shopping, Entertainment, Healthcare, Education, Other
- **Smart Forms**: Date picker, category selector, amount validation
- **Search & Filter**: Real-time search with time-based filtering
- **Bulk Operations**: Export, backup, and batch management

### 📊 Analytics & Reports
- **Interactive Charts**: Pie charts, bar graphs, trend analysis
- **Time-based Views**: Daily, weekly, monthly, yearly insights
- **Export Options**: PDF reports, CSV data export
- **Spending Patterns**: AI-powered financial insights

### 🔔 Smart Notifications
- **Expense Reminders**: Configurable notification system
- **Budget Alerts**: Threshold-based spending warnings
- **Insights Delivery**: Weekly/monthly financial summaries

## 🔐 Security Features

- **Firebase Authentication**: Secure user management
- **Local Encryption**: SQLite data protection
- **Permission Management**: Minimal required permissions
- **Data Privacy**: User-controlled cloud sync

## 🎨 UI/UX Features

- **Material Design 3**: Modern, adaptive UI
- **Dark/Light Themes**: System-adaptive theming
- **Smooth Animations**: Professional transitions
- **Responsive Design**: Works on all screen sizes
- **Accessibility**: Screen reader and keyboard navigation support

## 🐛 Known Issues

- Notes feature is basic (planned enhancement)
- Search could benefit from debouncing (performance optimization)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing BLoC pattern
- Add tests for new features
- Update documentation
- Ensure responsive design
- Follow Flutter/Dart style guide

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for backend services
- **Material Design** for design system
- **FL Chart** for beautiful visualizations
- **Community packages** used in this project

## 📞 Support

For support, email support@yourcompany.com or create an issue in the repository.

## 🔗 Links

- [Live Demo](https://your-demo-url.com)
- [API Documentation](docs/API.md)
- [User Guide](docs/USER_GUIDE.md)
- [Firebase Setup](docs/FIREBASE_SETUP.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>© 2024 SmartExpense Manager. All rights reserved.</p>
</div>