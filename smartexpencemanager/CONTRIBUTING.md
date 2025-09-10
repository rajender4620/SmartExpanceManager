# 🤝 Contributing to SmartExpense Manager

Thank you for considering contributing to SmartExpense Manager! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)

## 📖 Code of Conduct

### Our Pledge

We are committed to making participation in this project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team at conduct@smartexpensemanager.com.

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Flutter SDK** 3.16+ installed
- **Dart SDK** 3.0+
- **Git** for version control
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase account** for testing

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/smartexpensemanager.git
   cd smartexpensemanager
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/original-repo/smartexpensemanager.git
   ```

## 🛠️ Development Setup

### Initial Setup

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Configure Firebase** (for testing):
   - Follow the [Firebase Setup Guide](docs/FIREBASE_SETUP.md)
   - Use development Firebase project
   - Never commit production Firebase config

3. **Verify setup**:
   ```bash
   flutter doctor
   flutter test
   ```

### IDE Configuration

#### VS Code
Install recommended extensions:
- Flutter
- Dart
- GitLens
- Bracket Pair Colorizer
- Flutter Widget Snippets

#### Android Studio
Enable plugins:
- Flutter
- Dart
- Git Integration

## 📝 Contributing Guidelines

### Types of Contributions

We welcome various types of contributions:

#### 🐛 Bug Fixes
- Fix existing functionality issues
- Improve error handling
- Resolve performance problems

#### ✨ New Features
- Add new expense categories
- Implement additional chart types
- Create new export formats
- Enhance UI/UX

#### 📚 Documentation
- Improve existing documentation
- Add code comments
- Create tutorials
- Update API documentation

#### 🧪 Testing
- Add unit tests
- Create widget tests
- Implement integration tests
- Improve test coverage

#### 🎨 Design
- UI/UX improvements
- Icon and asset updates
- Animation enhancements
- Accessibility improvements

### Contribution Workflow

1. **Check existing issues** - Avoid duplicate work
2. **Create an issue** - Discuss your idea first
3. **Wait for approval** - Get maintainer feedback
4. **Create feature branch** - Work on approved changes
5. **Submit pull request** - Follow PR template
6. **Code review** - Address feedback
7. **Merge** - Celebrate your contribution!

## 🔄 Pull Request Process

### Before Creating a PR

- [ ] Search existing PRs to avoid duplicates
- [ ] Create/update tests for your changes
- [ ] Run full test suite locally
- [ ] Update documentation if needed
- [ ] Follow coding standards
- [ ] Test on multiple devices/platforms

### PR Template

When creating a pull request, use this template:

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
- [ ] Unit tests
- [ ] Widget tests
- [ ] Manual testing on Android
- [ ] Manual testing on iOS
- [ ] Manual testing on Web

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have made corresponding changes to documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective
- [ ] New and existing unit tests pass locally
```

### Review Process

1. **Automated checks** must pass
2. **At least one maintainer** review required
3. **Address feedback** promptly
4. **Squash commits** if requested
5. **Rebase** on latest main branch

## 🐛 Issue Reporting

### Bug Reports

When reporting bugs, include:

#### System Information
- **Device**: Model and OS version
- **App version**: Found in settings
- **Flutter version**: `flutter --version`
- **Platform**: Android/iOS/Web

#### Bug Description
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Steps to reproduce**: Detailed reproduction steps
- **Screenshots**: Visual evidence if applicable

#### Bug Report Template
```markdown
**Device Information:**
- Device: [e.g. iPhone 12, Samsung Galaxy S21]
- OS: [e.g. iOS 15.1, Android 12]
- App Version: [e.g. 1.2.3]

**Describe the bug:**
A clear description of what the bug is.

**To Reproduce:**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior:**
A clear description of what you expected to happen.

**Screenshots:**
If applicable, add screenshots to help explain your problem.

**Additional context:**
Add any other context about the problem here.
```

### Feature Requests

For feature requests, include:
- **Problem description**: What problem does this solve?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Other approaches considered
- **Additional context**: Any other relevant information

## 🔧 Development Workflow

### Branch Naming

Use descriptive branch names:
- `feature/expense-categories` - New features
- `bugfix/login-crash` - Bug fixes
- `docs/api-documentation` - Documentation
- `refactor/database-service` - Code refactoring

### Commit Messages

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(expenses): add recurring expense functionality

fix(auth): resolve Google Sign-In crash on Android

docs(readme): update installation instructions

test(database): add unit tests for expense service
```

### Development Cycle

1. **Sync with upstream**:
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

2. **Create feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes**:
   - Write code
   - Add tests
   - Update docs

4. **Test thoroughly**:
   ```bash
   flutter test
   flutter test integration_test/
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

6. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

## 📏 Coding Standards

### Dart Style Guide

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart):

#### Naming Conventions
```dart
// Classes - PascalCase
class ExpenseService {}

// Variables/Functions - camelCase
String userName = '';
void getUserExpenses() {}

// Constants - lowerCamelCase
const double maxExpenseAmount = 10000.0;

// Private members - leading underscore
String _privateVariable = '';
void _privateMethod() {}
```

#### File Organization
```dart
// 1. Imports - dart: first, package: second, relative: last
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/expense.dart';
import '../services/database_service.dart';

// 2. Main class
class ExpenseScreen extends StatelessWidget {
  // 3. Constructor
  const ExpenseScreen({super.key});
  
  // 4. Public methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 5. Private methods
  void _handleExpenseAdd() {}
}
```

### BLoC Pattern Standards

#### Event Classes
```dart
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();
  
  @override
  List<Object> get props => [];
}

class AddExpense extends ExpenseEvent {
  const AddExpense(this.expense);
  
  final Expense expense;
  
  @override
  List<Object> get props => [expense];
}
```

#### State Classes
```dart
class ExpenseState extends Equatable {
  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.expenses = const [],
    this.errorMessage,
  });
  
  final ExpenseStatus status;
  final List<Expense> expenses;
  final String? errorMessage;
  
  ExpenseState copyWith({
    ExpenseStatus? status,
    List<Expense>? expenses,
    String? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, expenses, errorMessage];
}
```

### UI Standards

#### Widget Composition
```dart
class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
  });
  
  final Expense expense;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.title),
      subtitle: Text(expense.category),
      trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
      onTap: onTap,
    );
  }
}
```

#### Responsive Design
```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return DesktopLayout();
        } else if (constraints.maxWidth > 600) {
          return TabletLayout();
        } else {
          return MobileLayout();
        }
      },
    );
  }
}
```

## 🧪 Testing Guidelines

### Test Structure

#### Unit Tests
```dart
void main() {
  group('DatabaseService', () {
    late DatabaseService databaseService;
    
    setUp(() {
      databaseService = DatabaseService();
    });
    
    test('should insert expense successfully', () async {
      // Arrange
      const expense = Expense(
        title: 'Test Expense',
        amount: 50.0,
        category: 'Food',
        date: '2024-01-01',
      );
      
      // Act
      final result = await databaseService.insertExpense(expense);
      
      // Assert
      expect(result, isNotNull);
      expect(result.length, greaterThan(0));
    });
  });
}
```

#### Widget Tests
```dart
void main() {
  testWidgets('ExpenseListItem displays expense information', (tester) async {
    // Arrange
    const expense = Expense(
      title: 'Test Expense',
      amount: 50.0,
      category: 'Food',
      date: '2024-01-01',
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseListItem(expense: expense),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Expense'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);
  });
}
```

#### BLoC Tests
```dart
void main() {
  group('ExpenseBloc', () {
    late ExpenseBloc expenseBloc;
    late MockDatabaseService mockDatabaseService;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      expenseBloc = ExpenseBloc(databaseService: mockDatabaseService);
    });
    
    tearDown(() {
      expenseBloc.close();
    });
    
    blocTest<ExpenseBloc, ExpenseState>(
      'emits loading then success when expenses are loaded',
      build: () {
        when(() => mockDatabaseService.getAllExpenses())
            .thenAnswer((_) async => [mockExpense]);
        return expenseBloc;
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseState(status: ExpenseStatus.loading),
        ExpenseState(
          status: ExpenseStatus.success,
          expenses: [mockExpense],
        ),
      ],
    );
  });
}
```

### Test Coverage

Maintain high test coverage:
- **Unit tests**: > 80% coverage
- **Widget tests**: Critical UI components
- **Integration tests**: Key user flows

Run coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Release Process

### Version Numbering

Follow semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Release Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run full test suite
- [ ] Test on multiple platforms
- [ ] Update documentation
- [ ] Create release tag
- [ ] Build and test release artifacts

## 🏆 Recognition

Contributors are recognized in several ways:

- **README.md**: Listed in contributors section
- **Release notes**: Mentioned in version releases
- **Hall of fame**: Special recognition for significant contributions
- **Swag**: T-shirts and stickers for major contributors

## 📞 Getting Help

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Email**: maintainers@smartexpensemanager.com
- **Discord**: [Community server link]

### Mentorship

New contributors can request mentorship:
- **Code reviews**: Detailed feedback on PRs
- **Pair programming**: Live coding sessions
- **Architecture guidance**: Help with complex features

## 📚 Resources

### Learning Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [BLoC Library](https://bloclibrary.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

### Project Resources
- [Architecture Decision Records](docs/ADR/)
- [API Documentation](docs/API.md)
- [User Guide](docs/USER_GUIDE.md)
- [Firebase Setup](docs/FIREBASE_SETUP.md)

---

Thank you for contributing to SmartExpense Manager! Together, we're building the best expense tracking app for everyone. 🎉

*Last updated: December 2024*
