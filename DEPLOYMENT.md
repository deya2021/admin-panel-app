# Deployment Guide - RationPoint Admin Panel

## 📋 Pre-Deployment Checklist

- [ ] Firebase project is set up
- [ ] Firebase CLI is installed (`npm install -g firebase-tools`)
- [ ] Logged into Firebase (`firebase login`)
- [ ] Flutter SDK is installed
- [ ] Node.js 18+ is installed

## 🚀 Step-by-Step Deployment

### 1. Deploy Cloud Functions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy all functions
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:statsOnUserWrite,functions:statsOnProductWrite,functions:statsOnOrderWrite,functions:recalcWeekly
```

**Expected Output:**
```
✔  functions[statsOnUserWrite] Successful update operation.
✔  functions[statsOnProductWrite] Successful update operation.
✔  functions[statsOnOrderWrite] Successful update operation.
✔  functions[recalcWeekly] Successful update operation.
```

### 2. Verify Functions Deployment

```bash
# List all deployed functions
firebase functions:list

# Expected functions:
# - statsOnUserWrite
# - statsOnProductWrite
# - statsOnOrderWrite
# - recalcWeekly
# - setUserRole
# - initializeUserRole
# - onNewRedemption
# - onRedemptionStatusChange
# - checkLowStock
# - onOrderCreated
# - onProductWrite
# - recalculateStats
```

### 3. Test recalcWeekly Function

#### Option A: From Firebase Console
1. Go to Firebase Console → Functions
2. Find `recalcWeekly` function
3. Click "Test function" (requires admin authentication)

#### Option B: From Command Line
```bash
firebase functions:shell

# In the shell:
recalcWeekly({}, {auth: {uid: 'YOUR_ADMIN_UID', token: {role: 'admin'}}})
```

#### Option C: From Flutter App
```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;
final callable = functions.httpsCallable('recalcWeekly');

try {
  final result = await callable.call();
  debugPrint('Success: ${result.data}');
} catch (e) {
  debugPrint('Error: $e');
}
```

### 4. Build and Run Flutter App

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on mobile
flutter run

# Build release APK (Android)
flutter build apk --release

# Build release IPA (iOS)
flutter build ios --release

# Build web
flutter build web
```

### 5. Verify Data Flow

1. **Check Firestore Document**:
   - Go to Firebase Console → Firestore
   - Navigate to `stats/main`
   - Verify `weeklyOrders` field exists with 7 integers

2. **Test Auto-Update**:
   - Create a new order in Firestore
   - Watch dashboard automatically update (within 1-2 seconds)

3. **Test Manual Refresh**:
   - Click refresh button in dashboard
   - Verify stats reload

4. **Test recalcWeekly**:
   - Call the function as admin
   - Check `weeklyOrders` updates in real-time

## 🔍 Troubleshooting

### Functions Won't Deploy
```bash
# Check Node.js version (must be 18+)
node --version

# Clear cache and reinstall
cd functions
rm -rf node_modules package-lock.json
npm install
npm run build
```

### StreamProvider Not Updating
- Check Firestore rules allow read access to `stats/main`
- Verify user is authenticated
- Check console for connection errors

### recalcWeekly Returns Permission Denied
- Verify user has `admin` role in custom claims
- Check Firebase Auth custom claims:
  ```javascript
  admin.auth().getUser(uid).then(user => {
    console.log(user.customClaims);
  });
  ```

### weeklyOrders Shows All Zeros
- Ensure orders have `createdAt` timestamp field
- Check orders are within last 7 days
- Verify orders collection has data

## 📊 Testing Data Flow

### Create Test Order
```javascript
// Add in Firestore Console or via app
{
  "userId": "test-user-id",
  "status": "pending",
  "total": 100,
  "createdAt": firebase.firestore.FieldValue.serverTimestamp()
}
```

### Verify Trigger Execution
```bash
# View function logs
firebase functions:log --only statsOnOrderWrite

# Expected output:
# Weekly orders recalculated
```

## 🎯 Post-Deployment Verification

### Checklist
- [ ] All Cloud Functions deployed successfully
- [ ] `stats/main` document exists with correct structure
- [ ] Dashboard loads without errors
- [ ] Stats cards show real data
- [ ] Weekly chart displays correctly (7 bars)
- [ ] Refresh button works
- [ ] Auto-update works when data changes
- [ ] recalcWeekly callable works for admins

### Expected Data Structure in Firestore
```json
{
  "stats/main": {
    "usersCount": 0,
    "productsCount": 0,
    "lowStockCount": 0,
    "pendingOrdersCount": 0,
    "weeklyOrders": [0, 0, 0, 0, 0, 0, 0],
    "lastUpdated": "2025-10-21T12:00:00Z"
  }
}
```

## 🔐 Security Notes

- Only admins can call `recalcWeekly`
- All functions require authentication
- Firestore rules should protect sensitive data
- Use environment variables for sensitive config

## 📝 Maintenance

### Regular Tasks
- Monitor function execution logs
- Check for errors in Firebase Console
- Review weeklyOrders accuracy
- Update dependencies monthly

### Performance Monitoring
```bash
# Check function performance
firebase functions:log --only statsOnOrderWrite --limit 50
```

## 🆘 Support

If issues persist:
1. Check Firebase Console → Functions → Logs
2. Review Firestore Rules
3. Verify user authentication and roles
4. Check app console for errors

---

**Last Updated**: October 21, 2025
**Version**: 2.0.0
