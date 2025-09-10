# 📚 API Documentation & Code Structure

This document provides comprehensive information about the SmartExpense Manager codebase, including architecture, services, and integration patterns.

## 🏗️ Architecture Overview

SmartExpense Manager follows **Clean Architecture** principles with **BLoC pattern** for state management:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Presentation  │    │   Business      │    │      Data       │
│     Layer       │◄──►│     Logic       │◄──►│     Layer       │
│                 │    │    Layer        │    │                 │
│ • Screens       │    │ • BLoCs         │    │ • Services      │
│ • Widgets       │    │ • Events        │    │ • Repositories  │
│ • Navigation    │    │ • States        │    │ • Models        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure Deep Dive

### `/lib` Directory
```
lib/
├── blocs/                  # State Management
│   ├── auth/              # Authentication BLoC
│   ├── expense/           # Expense Management BLoC  
│   ├── navigation/        # Navigation State BLoC
│   └── theme/             # Theme Management BLoC
├── models/                # Data Models
├── screens/               # UI Screens
├── services/              # Business Logic & Data Access
├── widgets/               # Reusable UI Components
├── theme/                 # App Theming
├── utils/                 # Helper Functions
└── main.dart             # Application Entry Point
```

## 🧠 BLoC Architecture

### Authentication BLoC

#### Events
```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class CheckAuthStatus extends AuthEvent {}
class GoogleSignInRequested extends AuthEvent {}
class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
}
class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
}
class PasswordResetRequested extends AuthEvent {
  final String email;
}
class SignOutRequested extends AuthEvent {}
```

#### States
```dart
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? userEmail;
  final String? userName;
  final String? userPhotoUrl;
  final String? errorMessage;
  
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}
```

#### Usage Example
```dart
// Trigger Google Sign-In
context.read<AuthBloc>().add(const GoogleSignInRequested());

// Listen to auth state changes
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state.isAuthenticated) {
      // Navigate to main app
    } else if (state.hasError) {
      // Show error message
    }
  },
  child: YourWidget(),
)
```

### Expense BLoC

#### Events
```dart
class LoadExpenses extends ExpenseEvent {}
class LoadExpensesByDateRange extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;
}
class LoadExpensesByTimeRange extends ExpenseEvent {
  final String timeRange; // 'Week', 'Month', 'Year'
}
class AddExpense extends ExpenseEvent {
  final Expense expense;
}
class UpdateExpense extends ExpenseEvent {
  final Expense expense;
}
class DeleteExpense extends ExpenseEvent {
  final String expenseId;
}
```

#### States
```dart
enum ExpenseStatus { initial, loading, success, failure }

class ExpenseState extends Equatable {
  final ExpenseStatus status;
  final List<Expense> expenses;
  final Map<String, double> categoryTotals;
  final Map<String, List<Expense>> expensesByCategory;
  final List<Map<String, dynamic>> trendData;
  final double totalExpenses;
  final String? errorMessage;
}
```

## 🗄️ Data Models

### Expense Model
```dart
class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Serialization
  Map<String, dynamic> toMap();
  factory Expense.fromMap(Map<String, dynamic> map);
  
  // Utility
  Expense copyWith({...});
}
```

### Category Model
```dart
class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;
  
  static List<ExpenseCategory> categories = [
    ExpenseCategory(name: 'Food & Dining', icon: Icons.restaurant, color: Color(0xFFFF9E80)),
    ExpenseCategory(name: 'Travel', icon: Icons.flight, color: Color(0xFF80DEEA)),
    // ... more categories
  ];
}
```

### Insight Model
```dart
enum InsightType { warning, success, info, tip }

class Insight {
  final String message;
  final InsightType type;
  final DateTime timestamp;
  
  IconData get icon;
  Color get color;
  LinearGradient get gradient;
}
```

## 🔧 Services Architecture

### Database Service
Local SQLite database management for offline-first functionality.

```dart
class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Singleton pattern
  factory DatabaseService() => _instance;
  
  // Core CRUD operations
  Future<String> insertExpense(Expense expense);
  Future<List<Expense>> getAllExpenses();
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  
  // Analytics operations
  Future<double> getTotalExpenses();
  Future<Map<String, double>> getTotalExpensesByCategory();
  Future<List<Expense>> getCurrentMonthExpenses();
}
```

#### Database Schema
```sql
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
```

### Firebase Services

#### Authentication Service
```dart
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password});
  Future<UserCredential> signUpWithEmailAndPassword({required String email, required String password, required String name});
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  
  // User state
  User? get currentUser;
  Stream<User?> get authStateChanges;
}
```

#### Firestore Database Service
```dart
class FirebaseFirestoreDb {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User management
  Future<void> addUser(User? user);
  Future<DocumentSnapshot> getUser(String docId);
  Stream<QuerySnapshot> getUsersStream();
  
  // Notes management
  Future<void> addNote();
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotesStream();
}
```

#### FCM Service
```dart
class FirebaseFcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  
  // Notification setup
  Future<void> requestNotificationPermission();
  Future<String?> getToken();
  void listenToMessages();
  
  // Internal methods
  Future<void> _initializeLocalNotifications();
  Future<void> _showLocalNotification(String title, String body);
}
```

### Utility Services

#### Insights Service
Generates AI-powered financial insights based on spending patterns.

```dart
class InsightsService {
  static const double SPENDING_INCREASE_THRESHOLD = 0.2;
  static const double BUDGET_WARNING_THRESHOLD = 0.8;
  
  static Future<List<Insight>> generateInsights();
  static Future<List<Insight>> _generateCategoryInsights(List<Expense> current, List<Expense> previous);
  static Future<List<Insight>> _generateSpendingPatternInsights(List<Expense> expenses);
  static Future<List<Insight>> _generateBudgetInsights(List<Expense> expenses);
}
```

#### Report Service
Handles data export and sharing functionality.

```dart
class ReportService {
  static Future<void> exportToCsv(List<Map<String, dynamic>> data);
  static Future<void> exportToPdf(List<Map<String, dynamic>> categoryData, List<Map<String, dynamic>> trendData);
}
```

#### Backup Service
Manages data backup and restore operations.

```dart
enum BackupFormat { json, csv, database }

class BackupService {
  static Future<File> exportToJson();
  static Future<File> exportToCsv();
  static Future<void> importFromJson(File file);
  static Future<void> shareBackup(BackupFormat format);
}
```

## 🎨 Theme Architecture

### App Theme
```dart
class AppTheme {
  // Light theme colors
  static const Color lightPrimaryColor = Color(0xFF00897B);
  static const Color lightSecondaryColor = Color(0xFF039BE5);
  
  // Dark theme colors  
  static const Color darkPrimaryColor = Color(0xFF26A69A);
  static const Color darkSecondaryColor = Color(0xFF42A5F5);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(primary: lightPrimaryColor, ...),
    textTheme: GoogleFonts.poppinsTextTheme(...),
    // ... more theme configuration
  );
  
  static ThemeData darkTheme = ThemeData(...);
}
```

### Theme BLoC
```dart
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<LoadTheme>(_onLoadTheme);
  }
  
  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit);
  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit);
}
```

## 🛣️ Navigation Architecture

### Navigation Service
Centralized navigation management with named routes.

```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Route constants
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String reports = '/reports';
  static const String insights = '/insights';
  
  // Navigation methods
  static void navigateToTab(BuildContext context, int tabIndex);
  static Route<dynamic> generateRoute(RouteSettings settings);
}
```

### Route Generation
```dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case dashboard:
      return MaterialPageRoute(
        builder: (context) {
          context.read<NavigationBloc>().add(const UpdateNavigationIndex(0));
          return const MainLayout();
        },
      );
    // ... more routes
  }
}
```

## 🔌 Integration Patterns

### BLoC Integration Example
```dart
class ExpensesScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        switch (state.status) {
          case ExpenseStatus.loading:
            return const CircularProgressIndicator();
          case ExpenseStatus.success:
            return ExpensesList(expenses: state.expenses);
          case ExpenseStatus.failure:
            return ErrorWidget(message: state.errorMessage);
          default:
            return const SizedBox();
        }
      },
    );
  }
}
```

### Service Integration
```dart
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseService _databaseService;
  
  ExpenseBloc({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService(),
        super(const ExpenseState());
  
  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseService.insertExpense(event.expense);
      // Reload expenses
      add(const LoadExpenses());
    } catch (e) {
      emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: e.toString()));
    }
  }
}
```

## 🧪 Testing Patterns

### Unit Test Example
```dart
void main() {
  group('ExpenseBloc', () {
    late ExpenseBloc expenseBloc;
    late MockDatabaseService mockDatabaseService;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      expenseBloc = ExpenseBloc(databaseService: mockDatabaseService);
    });
    
    blocTest<ExpenseBloc, ExpenseState>(
      'emits success state when expenses are loaded',
      build: () {
        when(() => mockDatabaseService.getAllExpenses())
            .thenAnswer((_) async => [mockExpense]);
        return expenseBloc;
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseState(status: ExpenseStatus.loading),
        ExpenseState(status: ExpenseStatus.success, expenses: [mockExpense]),
      ],
    );
  });
}
```

### Widget Test Example
```dart
void main() {
  testWidgets('LoginScreen shows email and password fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (context) => AuthBloc(),
          child: const LoginScreen(),
        ),
      ),
    );
    
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
```

## 🔒 Security Patterns

### Authentication Flow
```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            return const MainLayout();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          default:
            return const SplashScreen();
        }
      },
    );
  }
}
```

### Data Encryption
```dart
// Example for sensitive data handling
class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static Future<void> storeSecurely(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  static Future<String?> readSecurely(String key) async {
    return await _storage.read(key: key);
  }
}
```

## 📊 Performance Patterns

### Lazy Loading
```dart
class ExpensesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ExpenseListItem(expense: expenses[index]);
      },
    );
  }
}
```

### Memory Management
```dart
class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late TextEditingController _titleController;
  late AnimationController _animationController;
  
  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
```

## 🛠️ Extending the Application

### Adding New Features

#### 1. Create BLoC Structure
```dart
// 1. Define Events
abstract class NewFeatureEvent extends Equatable {}

// 2. Define States  
class NewFeatureState extends Equatable {}

// 3. Implement BLoC
class NewFeatureBloc extends Bloc<NewFeatureEvent, NewFeatureState> {}
```

#### 2. Add Service Layer
```dart
class NewFeatureService {
  Future<void> performOperation();
}
```

#### 3. Create UI Components
```dart
class NewFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewFeatureBloc(),
      child: BlocBuilder<NewFeatureBloc, NewFeatureState>(
        builder: (context, state) {
          // Build UI based on state
        },
      ),
    );
  }
}
```

#### 4. Update Navigation
```dart
// Add route to NavigationService
static const String newFeature = '/new-feature';

// Add route generation
case newFeature:
  return MaterialPageRoute(builder: (_) => const NewFeatureScreen());
```

## 📝 Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Keep functions small and focused
- Add comprehensive documentation

### BLoC Guidelines
- One BLoC per feature domain
- Keep BLoCs pure (no UI dependencies)
- Use sealed classes for events when possible
- Always handle loading and error states

### Service Guidelines
- Use dependency injection
- Keep services stateless
- Handle errors gracefully
- Add comprehensive logging

## 🔗 External Integrations

### Firebase Integration
```dart
// Initialize Firebase
await Firebase.initializeApp();

// Use Firebase services
final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
final messaging = FirebaseMessaging.instance;
```

### Chart Integration (FL Chart)
```dart
PieChart(
  PieChartData(
    sections: data.map((item) => PieChartSectionData(
      value: item.value,
      title: item.title,
      color: item.color,
    )).toList(),
  ),
)
```

This API documentation provides a comprehensive overview of the SmartExpense Manager architecture. For specific implementation details, refer to the source code and inline documentation.
