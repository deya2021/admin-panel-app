# CHANGELOG

## [2.0.0] - 2025-10-21

### ✨ Added
- **recalcWeekly()** - New callable Cloud Function for manual weekly orders recalculation
  - Admin-only access with role verification
  - Returns updated weeklyOrders array and success message
  - Exported in `functions/src/index.ts`

### 🔧 Enhanced
- **updateStats()** - Improved weekly orders computation
  - Ensures exactly 7 integers are always returned
  - Better date handling with proper bucketing logic
  - Index 0 = 6 days ago, Index 6 = today
  - Automatic updates on any user/product/order changes

### ⚡ Optimized
- **Dashboard Data Flow**
  - Real-time refresh using StreamProvider
  - Automatic UI updates when stats/main document changes
  - No manual refresh needed for most cases
  - Removed all print statements from providers

### 🧹 Code Cleanup
- **Linting & Best Practices**
  - Fixed all `use_super_parameters` warnings
  - Replaced `Key? key` with `super.key` throughout
  - Enabled `avoid_print` rule in analysis_options.yaml
  - Removed debug print statements from dashboard_providers.dart

### 📝 Files Modified
- `functions/src/updateStats.ts` - Enhanced weeklyOrders computation + recalcWeekly
- `functions/src/index.ts` - Export recalcWeekly function
- `lib/features/dashboard/providers/dashboard_providers.dart` - Removed prints, optimized streams
- `lib/features/dashboard/presentation/dashboard_screen.dart` - super.key fixes
- `lib/features/dashboard/widgets/stat_card_widget.dart` - super.key fixes
- `lib/features/dashboard/models/dashboard_stats.dart` - Code cleanup
- `analysis_options.yaml` - Enabled stricter linting rules
- `README.md` - Comprehensive documentation update

### 🔒 Security
- recalcWeekly requires admin authentication
- Proper error handling with Arabic error messages

### 📊 Data Structure
```typescript
weeklyOrders: [
  0, // 6 days ago
  1, // 5 days ago
  2, // 4 days ago
  3, // 3 days ago
  4, // 2 days ago
  5, // yesterday
  6  // today
]
```

### 🚀 Deployment
```bash
# Deploy functions
cd functions
npm run build
firebase deploy --only functions

# Run app
flutter pub get
flutter run
```

### 📖 Documentation
- Added comprehensive README with usage examples
- Documented recalcWeekly callable function
- Added data flow diagrams
- Arabic and English documentation

---

## [1.0.0] - Previous Version
- Initial dashboard implementation
- Basic stats tracking
- User/Product/Order management
