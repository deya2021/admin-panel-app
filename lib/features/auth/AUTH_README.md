# Auth Feature Module

Complete authentication feature module with Firebase integration, Riverpod state management, and RTL Arabic UI.

## 📁 Structure

```
lib/features/auth/
├── data/
│   └── auth_repository.dart          # Firebase Auth integration
├── providers/
│   └── auth_providers.dart           # Riverpod providers
├── presentation/
│   └── login_screen.dart             # Login UI with RTL support
└── AUTH_README.md                    # This file
```

## 🚀 Features

✅ **Firebase Authentication**
- Email/password sign-in
- Token refresh for custom claims
- Sign out functionality
- Error handling with Arabic messages

✅ **Riverpod State Management**
- `currentUserProvider` - Stream of current user
- `currentUserRoleProvider` - Stream of user role from custom claims
- `isAuthenticatedProvider` - Boolean authentication state
- `isAdminProvider` - Check if user is admin
- `isManagerOrAboveProvider` - Check if user is manager or admin

✅ **RTL Arabic UI**
- Beautiful Material 3 design
- Right-to-left layout
- Arabic error messages
- Form validation
- Loading states

## 📝 Usage

### 1. Check Authentication State

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_providers.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    if (isAuthenticated) {
      return Text('مرحباً!'); // Welcome!
    } else {
      return Text('يرجى تسجيل الدخول'); // Please login
    }
  }
}
```

### 2. Get Current User

```dart
final userAsync = ref.watch(currentUserProvider);

userAsync.when(
  data: (user) {
    if (user != null) {
      return Text('Email: ${user.email}');
    }
    return Text('لا يوجد مستخدم'); // No user
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('خطأ: $error'), // Error
);
```

### 3. Check User Role

```dart
final roleAsync = ref.watch(currentUserRoleProvider);

roleAsync.when(
  data: (role) {
    if (role?.isAdmin ?? false) {
      return AdminPanel();
    } else if (role?.isManagerOrAbove ?? false) {
      return ManagerPanel();
    } else {
      return UserPanel();
    }
  },
  loading: () => LoadingIndicator(),
  error: (error, stack) => ErrorView(error: error.toString()),
);
```

### 4. Sign Out

```dart
ElevatedButton(
  onPressed: () async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
  },
  child: Text('تسجيل الخروج'), // Logout
)
```

## 🔐 Firebase Setup

### 1. Enable Email/Password Authentication

Firebase Console → Authentication → Sign-in method → Email/Password → Enable

### 2. Set Custom Claims (Admin SDK)

```javascript
// Cloud Function or Admin SDK
const admin = require('firebase-admin');

await admin.auth().setCustomUserClaims(uid, {
  role: 'admin' // or 'manager' or 'user'
});
```

### 3. Test Login

Create a test user in Firebase Console:
- Email: `admin@example.com`
- Password: `Test123!`
- Set custom claim: `{"role": "admin"}`

## 🎨 UI Components

### Login Screen Features

- **Email Field**: LTR text direction for email input
- **Password Field**: Toggle visibility
- **Form Validation**: Email and password validation
- **Loading State**: Disabled inputs during login
- **Error Handling**: Arabic error messages
- **Responsive Design**: Works on all screen sizes

### Arabic Error Messages

| Firebase Error | Arabic Message |
|---------------|----------------|
| `user-not-found` | المستخدم غير موجود |
| `wrong-password` | كلمة المرور غير صحيحة |
| `invalid-email` | البريد الإلكتروني غير صحيح |
| `user-disabled` | تم تعطيل هذا الحساب |
| `too-many-requests` | محاولات كثيرة، حاول لاحقاً |

## 🔄 Integration with Router

The auth module integrates seamlessly with `app_router.dart`:

```dart
redirect: (BuildContext context, GoRouterState state) {
  final isLoggedIn = isAuthenticated;
  final isLoginRoute = state.matchedLocation == '/login';

  // Redirect to login if not authenticated
  if (!isLoggedIn && !isLoginRoute) {
    return '/login';
  }

  // Redirect to home if already authenticated
  if (isLoggedIn && isLoginRoute) {
    return '/';
  }

  return null; // No redirect
},
```

## 🧪 Testing

### Test Login Flow

1. Run the app: `flutter run -d chrome`
2. You should see the login screen
3. Enter test credentials
4. On success, you'll be redirected to the dashboard
5. Click logout to return to login screen

### Test Role-Based Access

```dart
// In your dashboard or admin panel
final isAdmin = ref.watch(isAdminProvider);

if (isAdmin) {
  // Show admin-only features
}
```

## 📚 Dependencies

Required in `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
```

## 🎯 Next Steps

1. **Add Password Reset**: Implement forgot password flow
2. **Add Phone Auth**: Add phone number authentication
3. **Add Social Login**: Google, Apple, etc.
4. **Add Biometric Auth**: Fingerprint/Face ID
5. **Add Remember Me**: Persistent login option

## 💡 Best Practices

✅ Always refresh token after login to get updated custom claims  
✅ Handle all Firebase auth errors gracefully  
✅ Use loading states during async operations  
✅ Validate forms before submission  
✅ Show user-friendly error messages in Arabic  
✅ Test with different user roles  

## 🐛 Troubleshooting

### Issue: Custom claims not updating

**Solution**: Call `refreshToken()` after setting custom claims:

```dart
await authRepo.refreshToken();
```

### Issue: Redirect loop

**Solution**: Check your router redirect logic and ensure authentication state is properly watched.

### Issue: Arabic text not displaying correctly

**Solution**: Ensure your app has RTL support in `main.dart`:

```dart
builder: (context, child) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: child!,
  );
},
```

---

**Created with ❤️ for the Admin Panel App**

**Default Language: العربية (Arabic) with full RTL support**

