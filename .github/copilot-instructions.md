# Saint John School Management System - Project Instructions

## 📱 Project Overview

**Application Name:** Saint John School Management System  
**Platform:** Mobile (Flutter)  
**State Management:** Riverpod  
**Current Phase:** UI Development with Dummy Data

This is a School Management System mobile application designed for Parents and Students with modern UI/UX, smooth animations, and a professional blue theme.

---

## 🏗️ Architecture & Structure

### Clean Architecture with Feature-First Approach

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_assets.dart
│   │   └── app_routes.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── theme_provider.dart
│   │
│   ├── utils/
│   │   ├── extensions/
│   │   ├── helpers/
│   │   └── validators/
│   │
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   ├── l10n/
│   │   │   ├── app_en.arb
│   │   │   └── app_id.arb
│   │   └── locale_provider.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   │
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
│
├── shared/
│   ├── widgets/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── inputs/
│   │   ├── dialogs/
│   │   ├── loading/
│   │   └── animations/
│   │
│   ├── providers/
│   │   └── shared_providers.dart
│   │
│   └── data/
│       └── dummy/
│           ├── dummy_students.dart
│           ├── dummy_schedules.dart
│           └── dummy_users.dart
│
├── features/
│   ├── splash/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── splash_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── widgets/
│   │   │   └── controllers/
│   │   └── providers/
│   │       └── auth_provider.dart
│   │
│   ├── dashboard/
│   │   ├── parent/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── parent_dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── providers/
│   │   │
│   │   └── student/
│   │       ├── presentation/
│   │       │   ├── screens/
│   │       │   │   └── student_dashboard_screen.dart
│   │       │   └── widgets/
│   │       └── providers/
│   │
│   ├── students/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── student_list_screen.dart
│   │   │   │   └── student_registration_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── assessment/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── schedule/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── schedule_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── academic_calendar/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── reports/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── attendance_report_screen.dart
│   │   │   │   ├── exam_schedule_screen.dart
│   │   │   │   ├── session_attendance_screen.dart
│   │   │   │   └── student_progress_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   ├── guide/
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── contact/
│   │   ├── presentation/
│   │   └── providers/
│   │
│   ├── notifications/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── notifications_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │
│   └── settings/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       │   ├── screens/
│       │   │   ├── settings_screen.dart
│       │   │   └── profile_screen.dart
│       │   └── widgets/
│       └── providers/
│
└── routing/
    ├── app_router.dart
    └── route_guards.dart
```

---

## 🎨 Design System & Theme

### Color Palette (Blue Theme)

```dart
// Primary Colors
static const Color primary = Color(0xFF1565C0);        // Main Blue
static const Color primaryLight = Color(0xFF5E92F3);   // Light Blue
static const Color primaryDark = Color(0xFF003C8F);    // Dark Blue

// Secondary Colors
static const Color secondary = Color(0xFF42A5F5);      // Accent Blue
static const Color secondaryLight = Color(0xFF80D6FF);
static const Color secondaryDark = Color(0xFF0077C2);

// Background Colors
static const Color background = Color(0xFFF5F9FF);     // Light Blue Tint
static const Color surface = Color(0xFFFFFFFF);
static const Color cardBackground = Color(0xFFFFFFFF);

// Text Colors
static const Color textPrimary = Color(0xFF1A1A2E);
static const Color textSecondary = Color(0xFF6B7280);
static const Color textOnPrimary = Color(0xFFFFFFFF);

// Status Colors
static const Color success = Color(0xFF10B981);
static const Color warning = Color(0xFFF59E0B);
static const Color error = Color(0xFFEF4444);
static const Color info = Color(0xFF3B82F6);

// Gradient
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

### Typography

- **Headlines:** Poppins (Bold/SemiBold)
- **Body Text:** Inter (Regular/Medium)
- **Buttons:** Poppins (SemiBold)

### Spacing & Dimensions

```dart
// Padding
static const double paddingXS = 4.0;
static const double paddingS = 8.0;
static const double paddingM = 16.0;
static const double paddingL = 24.0;
static const double paddingXL = 32.0;

// Border Radius
static const double radiusS = 8.0;
static const double radiusM = 12.0;
static const double radiusL = 16.0;
static const double radiusXL = 24.0;
static const double radiusCircular = 100.0;

// Elevation
static const double elevationS = 2.0;
static const double elevationM = 4.0;
static const double elevationL = 8.0;
```

---

## ✨ UI/UX Guidelines

### Animation Requirements

1. **Page Transitions:** Use smooth slide/fade transitions (300-400ms)
2. **Button Press:** Scale animation with haptic feedback
3. **Loading States:** Shimmer effect for skeleton loading
4. **List Items:** Staggered animation on load
5. **Cards:** Subtle elevation change on tap
6. **Pull to Refresh:** Custom animated indicator
7. **Hero Animations:** For image/avatar transitions

### Animation Durations

```dart
static const Duration fast = Duration(milliseconds: 150);
static const Duration normal = Duration(milliseconds: 300);
static const Duration slow = Duration(milliseconds: 500);
static const Duration verySlow = Duration(milliseconds: 800);
```

### Component Standards

- All buttons must have loading states
- Forms must have real-time validation feedback
- Empty states must have illustrations and action buttons
- Error states must be user-friendly with retry options
- All interactive elements must have proper touch targets (min 48x48)

---

## 📱 Screen Specifications

### 1. Splash Screen
- Display logo from `assets/icons/saintjohnlogo.png`
- Animated logo entrance (fade + scale)
- App name with typewriter or fade effect
- Loading indicator
- Auto-navigate to Login after 2-3 seconds

### 2. Authentication Screens

#### Login Screen
- Two tabs/options: "Login as Parent" | "Login as Student"
- Email/Username field
- Password field with visibility toggle
- "Remember Me" checkbox
- "Forgot Password?" link
- Login button with loading state
- "Don't have an account? Sign Up" link
- Social login options (optional for future)

#### Sign Up Screen
- User type selection (Parent/Student)
- Full name field
- Email field
- Phone number field
- Password field with strength indicator
- Confirm password field
- Terms & conditions checkbox
- Sign Up button
- "Already have an account? Login" link

#### Forgot Password Screen
- Email field
- Send Reset Link button
- Back to Login link
- Success/Error states

### 3. Dashboard Screens

#### Parent Dashboard
- Welcome header with user name and avatar
- Notification bell icon (top right)
- Menu cards:
  1. **Students**
     - Registration (add new student)
     - Student List (registered students)
  2. **Guide** (help/tutorial)
  3. **Contact Us**
- Bottom navigation: Dashboard | Settings

#### Student Dashboard
- Welcome header with user name and avatar
- Notification bell icon (top right)
- Current class/grade info
- Menu cards:
  1. **Assessment** (grades/nilai)
  2. **Jadwal Pelajaran** (class schedule)
  3. **Kalender Akademik** (academic calendar)
  4. **Laporan** (reports submenu):
     - Kehadiran Siswa (attendance)
     - Jadwal Ujian Hari Ini (today's exam schedule)
     - Kehadiran per Sesi Hari Ini (session attendance)
     - Progress Pencapaian Siswa (progress)
- Bottom navigation: Dashboard | Settings

### 4. Settings Screen
- Profile header with avatar and name
- **My Profile** - Edit profile information
- **Language** - Change language (EN/ID)
- **Notifications** - Toggle settings
- **About App** - Version info
- **Log Out** - With confirmation dialog

### 5. Notifications Screen
- List of notifications
- Read/Unread states
- Timestamp
- Different notification types (info, warning, success)
- Mark all as read option
- Empty state if no notifications

---

## 🌐 Localization

### Supported Languages
- English (en) - Default
- Indonesian (id)

### String Management Rules
1. **NEVER** hardcode strings in widgets
2. All user-facing text must use localization keys
3. Use ARB files for translations
4. Structure keys by feature: `feature_screen_element`

### Example Keys
```dart
// Auth
'auth_login_title': 'Login',
'auth_login_as_parent': 'Login as Parent',
'auth_login_as_student': 'Login as Student',
'auth_email_hint': 'Enter your email',
'auth_password_hint': 'Enter your password',

// Dashboard
'dashboard_welcome': 'Welcome, {name}',
'dashboard_students': 'Students',
'dashboard_assessment': 'Assessment',

// Common
'common_submit': 'Submit',
'common_cancel': 'Cancel',
'common_save': 'Save',
'common_loading': 'Loading...',
```

---

## 📦 State Management (Riverpod)

### Provider Organization

```dart
// Feature-specific providers in feature/providers/ folder
// Shared providers in shared/providers/ folder

// Provider naming convention
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
final userProvider = FutureProvider<User>(...);
final studentsListProvider = FutureProvider<List<Student>>(...);

// Use family for parameterized providers
final studentProvider = FutureProvider.family<Student, String>((ref, id) {...});
```

### State Classes

```dart
// Use freezed for immutable state classes
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

---

## 🗃️ Dummy Data Structure

### Location
All dummy data should be in `lib/shared/data/dummy/`

### Example Structures

```dart
// dummy_users.dart
class DummyUsers {
  static final List<User> parents = [...];
  static final List<User> students = [...];
}

// dummy_students.dart
class DummyStudents {
  static final List<Student> students = [...];
}

// dummy_schedules.dart
class DummySchedules {
  static final List<Schedule> schedules = [...];
}
```

---

## 📁 Asset Management

### Structure
```
assets/
├── icons/
│   ├── saintjohnlogo.png          # App logo
│   ├── menu/                       # Menu icons
│   └── navigation/                 # Nav icons
├── images/
│   ├── illustrations/              # Empty states, onboarding
│   ├── backgrounds/                # Background images
│   └── avatars/                    # Default avatars
├── animations/                      # Lottie files
└── fonts/
    ├── Poppins/
    └── Inter/
```

### Asset Constants
```dart
class AppAssets {
  static const String logo = 'assets/icons/saintjohnlogo.png';
  static const String defaultAvatar = 'assets/images/avatars/default.png';
  // ... etc
}
```

---

## 🛠️ Development Guidelines

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `login_screen.dart` |
| Classes | PascalCase | `LoginScreen` |
| Variables | camelCase | `userName` |
| Constants | camelCase/SCREAMING_SNAKE | `primaryColor` / `API_KEY` |
| Providers | camelCase + Provider suffix | `authStateProvider` |
| Private | _prefix | `_privateMethod` |

### File Naming

- Screens: `*_screen.dart`
- Widgets: `*_widget.dart` or descriptive name
- Providers: `*_provider.dart`
- Models: `*_model.dart`
- Entities: `*_entity.dart` (no suffix also acceptable)
- Repositories: `*_repository.dart`
- Controllers: `*_controller.dart`

### Code Style

1. Max line length: 80 characters
2. Use trailing commas for better formatting
3. Sort imports alphabetically (dart → package → relative)
4. Use explicit types for public APIs
5. Document public classes and complex methods

### Widget Guidelines

1. Keep widgets small and focused
2. Extract reusable widgets to shared/widgets
3. Use const constructors where possible
4. Prefer composition over inheritance
5. Use keys for list items

---

## 📦 Required Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Routing
  go_router: ^13.0.0
  
  # UI/Animations
  flutter_animate: ^4.3.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  lottie: ^2.7.0
  
  # Forms & Validation
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0
  
  # Utils
  intl: ^0.18.1
  flutter_screenutil: ^5.9.0
  shared_preferences: ^2.2.2
  
  # Icons
  iconsax: ^0.0.8
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  freezed: ^2.4.5
  freezed_annotation: ^2.4.1
  json_serializable: ^6.7.1
```

---

## ✅ Code Review Checklist

Before completing any feature:

- [ ] No hardcoded strings (use localization)
- [ ] No hardcoded colors (use AppColors)
- [ ] No hardcoded dimensions (use AppDimensions)
- [ ] Proper error handling
- [ ] Loading states implemented
- [ ] Empty states implemented
- [ ] Animations added where appropriate
- [ ] Responsive design considered
- [ ] Code documented
- [ ] Widgets are reusable where applicable

---

## 🔄 Git Workflow

### Branch Naming
- Feature: `feature/feature-name`
- Bugfix: `bugfix/bug-description`
- Hotfix: `hotfix/issue-description`
- Release: `release/v1.0.0`

### Commit Messages
```
type(scope): description

feat(auth): add login screen
fix(dashboard): resolve navigation issue
style(theme): update primary color
refactor(providers): optimize state management
docs(readme): update setup instructions
```

---

## 📋 Implementation Priority

### Phase 1 - Foundation
1. ✅ Project setup
2. Set up folder structure
3. Configure theme and colors
4. Add dependencies
5. Set up routing
6. Create base widgets

### Phase 2 - Authentication
1. Splash screen
2. Login screen
3. Sign up screen
4. Forgot password screen

### Phase 3 - Parent Flow
1. Parent dashboard
2. Student registration
3. Student list
4. Guide screen
5. Contact us screen

### Phase 4 - Student Flow
1. Student dashboard
2. Assessment screen
3. Schedule screen
4. Academic calendar
5. Reports screens

### Phase 5 - Common Features
1. Settings screen
2. Profile screen
3. Notifications screen
4. Localization setup

### Phase 6 - Polish
1. Animations refinement
2. Performance optimization
3. Testing
4. Bug fixes

---

## 🚨 Important Notes

1. **Always use the established folder structure** - Do not create files outside the defined architecture
2. **Localization first** - Never add user-facing text without localization keys
3. **Theme compliance** - Always use colors from AppColors, never hardcode
4. **Riverpod patterns** - Follow established provider patterns for consistency
5. **Animation consistency** - Use defined animation durations and curves
6. **Dummy data isolation** - Keep all dummy data in designated folders for easy replacement later
7. **No production backend access** - Never use production API endpoints, tokens, or credentials during development/testing. Only use non-production environments (dev/qa/staging/sandbox).

---

## 📝 Future Considerations

As the project grows, these features may be added:
- Push notifications integration
- Real API integration
- Offline support
- Biometric authentication
- Dark mode support
- More language options
- Analytics integration
- Crash reporting

---

*Last Updated: March 2026*
*Version: 1.0.0*
