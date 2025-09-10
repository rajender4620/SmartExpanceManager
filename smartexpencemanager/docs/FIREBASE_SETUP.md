# 🔥 Firebase Setup Guide

This guide will help you configure Firebase for the SmartExpense Manager application.

## 📋 Prerequisites

- **Firebase Account**: Sign up at [firebase.google.com](https://firebase.google.com)
- **Flutter Project**: SmartExpense Manager cloned and ready
- **Node.js**: For Firebase CLI (optional but recommended)

## 🚀 Quick Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `smart-expense-manager` (or your preference)
4. Enable/disable Google Analytics (recommended: Enable)
5. Choose or create Analytics account
6. Click **"Create project"**

### Step 2: Add Android App

1. In Firebase Console, click **"Add app"** → **Android**
2. **Android package name**: `com.yourcompany.smartexpensemanager`
   > ⚠️ **Important**: Change from `com.example.smartexpencemanager` to your domain
3. **App nickname**: `SmartExpense Manager Android`
4. **Debug signing certificate SHA-1**: Optional for development
5. Click **"Register app"**

### Step 3: Download Configuration Files

#### Android Configuration
1. Download `google-services.json`
2. Place it in `android/app/google-services.json`
3. **Verify placement**:
   ```
   android/
   ├── app/
   │   ├── google-services.json  ← HERE
   │   ├── build.gradle.kts
   │   └── src/
   ```

#### iOS Configuration (if needed)
1. In Firebase Console, click **"Add app"** → **iOS**
2. **iOS bundle ID**: `com.yourcompany.smartexpensemanager`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### Step 4: Configure Gradle (Android)

The project is already configured, but verify these files:

**`android/build.gradle.kts`**:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

**`android/app/build.gradle.kts`**:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← Verify this line
}

dependencies {
    // Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.1.0"))
    implementation("com.google.firebase:firebase-messaging")
}
```

## 🔧 Firebase Services Configuration

### 1. Authentication Setup

#### Enable Authentication Providers
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable these providers:

**Email/Password**:
- Click **"Email/Password"**
- Toggle **"Enable"**
- Save

**Google Sign-In**:
- Click **"Google"**
- Toggle **"Enable"**
- Add your **project support email**
- Download updated config files if prompted
- Save

#### Configure OAuth (Google Sign-In)
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. Navigate to **APIs & Services** → **Credentials**
4. Find **OAuth 2.0 Client IDs**
5. Note the **Web client ID** for Flutter configuration

### 2. Firestore Database Setup

1. In Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (we'll secure it later)
4. Select a location (choose closest to your users)
5. Click **"Done"**

#### Configure Security Rules
Replace default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's expenses
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's notes
      match /notes/{noteId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public read-only data (if any)
    match /categories/{document} {
      allow read: if request.auth != null;
    }
  }
}
```

### 3. Firebase Cloud Messaging (FCM)

#### Android FCM Setup
1. In Firebase Console → **Cloud Messaging**
2. No additional setup needed - already configured in the app

#### Generate Server Key (for backend notifications)
1. Go to **Project Settings** → **Cloud Messaging**
2. Copy **Server key** (if you plan to send notifications from backend)

### 4. Firebase Storage (Optional)

If you plan to store files:
1. In Firebase Console → **Storage**
2. Click **"Get started"**
3. Use default security rules for now
4. Choose storage location

## 🔐 Security Configuration

### Environment Variables

For sensitive configurations, create a `.env` file (add to `.gitignore`):

```env
# .env (DO NOT COMMIT TO GIT)
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### Production Security Rules

Update Firestore rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Authenticated users only
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // User-specific data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
      
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && 
          request.auth.uid == userId;
      }
    }
  }
}
```

## 📱 App Configuration Updates

### Update Package Name

**CRITICAL**: Change the package name from the default:

**Android** (`android/app/build.gradle.kts`):
```kotlin
defaultConfig {
    applicationId = "com.yourcompany.smartexpensemanager"  // Change this
    minSdk = 23
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.smartexpensemanager</string>
```

### Verify Firebase Integration

Add this test to verify Firebase is working:

```dart
// lib/test_firebase.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testFirebaseConnection() async {
  await Firebase.initializeApp();
  print('✅ Firebase connected successfully');
  
  final auth = FirebaseAuth.instance;
  print('✅ Firebase Auth initialized');
  
  // Test anonymous sign-in
  try {
    await auth.signInAnonymously();
    print('✅ Anonymous auth successful');
    await auth.signOut();
  } catch (e) {
    print('❌ Auth test failed: $e');
  }
}
```

## 🧪 Testing Firebase Setup

### 1. Test Authentication
```bash
flutter run
# Try signing up with email
# Try Google Sign-In
```

### 2. Test Firestore
```bash
# Add an expense and check Firebase Console
# Verify data appears in Firestore
```

### 3. Test FCM
```bash
# Check if FCM token is generated
# Send test notification from Firebase Console
```

## ❗ Common Issues & Solutions

### Issue: `google-services.json` not found
**Solution**: Ensure file is in `android/app/` directory, not `android/`

### Issue: Google Sign-In fails
**Solutions**:
1. Check SHA-1 fingerprint in Firebase Console
2. Verify package name matches exactly
3. Update Google Play Services on device/emulator

### Issue: Firestore permission denied
**Solution**: Check security rules and ensure user is authenticated

### Issue: FCM not receiving notifications
**Solutions**:
1. Check permissions in app settings
2. Verify `google-services.json` is correct
3. Test on physical device (not emulator)

## 📋 Production Checklist

- [ ] Change package name from `com.example.*`
- [ ] Update Firebase security rules
- [ ] Add SHA-1 fingerprint for release keystore
- [ ] Test all Firebase features
- [ ] Remove debug Firebase configurations
- [ ] Set up Firebase Analytics (optional)
- [ ] Configure Firebase Performance (optional)
- [ ] Set up Crashlytics (optional)

## 🔗 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase CLI](https://firebase.google.com/docs/cli)

## 🆘 Support

If you encounter issues:
1. Check [Firebase Status](https://status.firebase.google.com/)
2. Review [FlutterFire Documentation](https://firebase.flutter.dev/)
3. Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter+firebase)
4. Open an issue in this repository

---

✅ **Next Step**: After Firebase setup, proceed to [Deployment Guide](DEPLOYMENT.md)
