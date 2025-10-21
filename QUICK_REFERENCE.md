# Quick Reference Card - RationPoint Dashboard

## 🔧 New Features (v2.0.0)

### recalcWeekly() Function
**Purpose**: Manually recalculate weekly orders statistics

**Access**: Admin only

**Call from Flutter**:
```dart
final result = await FirebaseFunctions.instance
    .httpsCallable('recalcWeekly')
    .call();
```

**Response**:
```json
{
  "success": true,
  "weeklyOrders": [0, 1, 2, 3, 4, 5, 6],
  "message": "تم إعادة حساب الطلبات الأسبوعية بنجاح"
}
```

---

## 📊 weeklyOrders Array Structure

```
Index:  [0]    [1]    [2]    [3]    [4]    [5]    [6]
Day:    -6     -5     -4     -3     -2     -1     TODAY
        ↓      ↓      ↓      ↓      ↓      ↓      ↓
        Oldest                              Newest
```

**Always**: Exactly 7 integers, never null or undefined

---

## 🔄 Auto-Update Triggers

Dashboard updates automatically when:
- ✅ User created/updated/deleted
- ✅ Product created/updated/deleted  
- ✅ Order created/updated/deleted
- ✅ recalcWeekly() is called

**Update Speed**: < 1 second

---

## 🎨 UI Components

### Stats Cards (4)
1. **Total Users** - Blue icon
2. **Total Products** - Green icon
3. **Low Stock** - Orange warning icon
4. **Pending Redemptions** - Red pending icon

### Weekly Chart
- 7-bar horizontal chart
- Arabic day labels: [س، أ، ث، أر، خ، ج، س]
- Auto-scales based on max value

### Refresh Button
- Manual refresh trigger
- Invalidates both providers
- Shows loading state

---

## 🚀 Quick Commands

### Deploy Functions
```bash
cd functions && npm run build && firebase deploy --only functions
```

### Run App
```bash
flutter pub get && flutter run
```

### Check Logs
```bash
firebase functions:log --only statsOnOrderWrite
```

### Test Function
```bash
firebase functions:shell
> recalcWeekly({}, {auth: {uid: 'admin-id', token: {role: 'admin'}}})
```

---

## 🐛 Troubleshooting

### Dashboard Not Updating?
1. Check internet connection
2. Verify Firestore rules allow read
3. Check console for errors
4. Try manual refresh button

### weeklyOrders Shows All Zeros?
1. Check orders have `createdAt` field
2. Verify orders exist in last 7 days
3. Call recalcWeekly() manually
4. Check Firestore `stats/main` document

### recalcWeekly Permission Denied?
1. User must have `admin` role
2. Check custom claims in Firebase Auth
3. Verify authentication token

---

## 📝 Code Patterns

### Watch Real-Time Data
```dart
final stats = ref.watch(dashboardStatsProvider);
final weekly = ref.watch(weeklyOrdersProvider);
```

### Refresh Data
```dart
ref.invalidate(dashboardStatsProvider);
ref.invalidate(weeklyOrdersProvider);
```

### Error Handling
```dart
statsAsync.when(
  data: (stats) => ShowStats(),
  loading: () => ShowLoading(),
  error: (error, stack) => ShowError(),
);
```

---

## 🔐 Security Rules

### Firestore
```javascript
match /stats/main {
  allow read: if request.auth != null;
  allow write: if false; // Only functions can write
}
```

### Functions
- recalcWeekly: Admin only
- Triggers: Automatic, no auth needed

---

## 📞 Support Contacts

- **Firebase Console**: https://console.firebase.google.com
- **Documentation**: See README.md
- **Deployment Guide**: See DEPLOYMENT.md
- **Changelog**: See CHANGELOG.md

---

**Version**: 2.0.0  
**Last Updated**: October 21, 2025  
**Status**: Production Ready ✅
